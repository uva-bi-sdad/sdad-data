if (!require(soilDB)) install.packages('soilDB')
library(soilDB)
library(sp)
library(sf)
library(ggplot2)
library(sdalr)
library(dplyr)

# Find Soil Components By mukey ----------------------------------------------

query <- "SELECT
mukey, cokey, comppct_r, compname, taxorder, taxclname
FROM component
WHERE mukey = '123057'"

# run the query
res <- SDA_query(query)

# check
head(res)
class(res)


# Find Soil Components By Area Symbol ----------------------------------------------
area_symbol <- "VA059" #Arlington County, VA

query <- paste0("SELECT
component.mukey, cokey, comppct_r, compname, taxclname,
taxorder, taxsuborder, taxgrtgroup, taxsubgrp
FROM legend
INNER JOIN mapunit ON mapunit.lkey = legend.lkey
INNER JOIN component ON component.mukey = mapunit.mukey
WHERE taxsuborder LIKE 'And%'")
#WHERE legend.areasymbol = '", area_symbol, "'")

# run the query
res <- SDA_query(query)
# check
head(res)



# Find mukey for a Specific Point ----------------------------------------------

long <- -77.12369
lat <- 38.88392
p <- SpatialPoints(cbind(long, lat), proj4string = CRS('+proj=longlat +datum=WGS84'))
latlong = SDA_make_spatial_query(p)


# Get Geography Shapefile for Specific mukey ----------------------------------------------
query <- "SELECT G.MupolygonWktWgs84 as geom, '123057' as mukey from SDA_Get_MupolygonWktWgs84_from_Mukey('123057') as G"
res <- SDA_query(query)
str(res)
# convert to SPDF
s <- processSDA_WKT(res)
plot(s)


# Find mukeys for Specific Geographies ----------------------------------------------

# get Virginia Block Group Shapefile
con <- con_db("sdal")
bg <- st_read(con, c("geospatial$census_cb", "cb_2016_51_bg_500k"))

# Subset to just Arlington County FIPS Code
bg13 <- bg[bg$COUNTYFP=="013",]
head(bg13)

# Plot with Labels -- SEE BELOW

# subset further to specific census tract and block group
bg13_100700_3 <- bg13[bg13$TRACTCE=="100700" & bg13$NAME=="3",]

# make spatial query to gt mukeys for that area
bg13_100700_3_sp <- as(bg13_100700_3, 'Spatial')
soil_query <- SDA_make_spatial_query(bg13_100700_3_sp)
head(soil_query)

# get mukey data from list of mukeys
mukeys <- soil_query$mukey

data_list <- lapply(mukeys, function(x) {
  query <- paste0("SELECT mukey, cokey, comppct_r, compname, taxorder, taxclname
                   FROM component
                   WHERE mukey = '", x, "'")
  SDA_query(query)
})

mukey_data <- do.call("rbind", data_list)
head(mukey_data)


# PLOT WITH LABELS ----------------------------------------------

# Rename geometry column for plotting
colnames(bg13)[colnames(bg13)=="wkb_geometry"] <- "geometry"
st_geometry(bg13) <- "geometry"

# Get long lats of block group centroids and add as columns to sf object
bg_13_coords <- bg13 %>%
  st_centroid %>%
  st_coordinates
bg13$long <- bg_13_coords[,1]
bg13$lat <- bg_13_coords[,2]

# plot map with census tract + tract blockgroup as name
ggplot(bg13) +
  geom_sf(aes(fill = ALAND)) +
  geom_label(aes(long, lat, label = paste(TRACTCE, NAME)), alpha = 0.75, size = 2)

