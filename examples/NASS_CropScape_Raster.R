library(raster)
s <- brick("data/sdal_data/original/NASS_VA/cdl_30m_r_va_2008_utm17.tif")
nlayers(s)
ncell(s)
crs(s)
plot(s)
head(s)
inMemory(s)

vals <- getValues(s)
hist(vals)
data.table::as.data.table(vals)



library(raster)
library(sf)
# ACRES OF LAND USE TYPE FOR A COUNTY ----------------------------------------------

r = raster("data/sdal_data/original/CDL_2015_51.tif")
plot(r)
con <- sdalr::con_db("sdal")
sf = st_read(con, c("geospatial$census_tl", "tl_2017_us_county"))
sf_va <- sf[sf$STATEFP=="51" & sf$COUNTYFP=="013",]
sp_va = as(st_geometry(sf_va), 'Spatial')

p <- sp::spTransform(sp_va, crs(r))

plot(r)
lines(p)
plot(p)
r2 = mask(r,p)
plot(r2)
trim(r2, values = NA)
plot(r2)

c <- crop(r, p)
c2 <- mask(c, p)
c2[c2==0] <- NA
plot(c2)

table(getValues(c2))

c2v <- getValues(c2)
sum(c2[c2==5])

unique(c2v)


aggregate(getValues(area(c2, weights=FALSE)), by=list(getValues(c2)), sum)

c2f <- c2
crs(c2f) <- CRS("+init=epsg:2283")
crs(c2)
crs(c2f)

sqm <- data.table::setDT(aggregate(getValues(area(c2f, weights=FALSE)), by=list(getValues(c2f)), sum))
sqm[,.(Group.1, x, acres=x*0.00024711)]


# ACRES OF LAND USE TYPE FOR COUNTY BLOCK GROUPS ----------------------------------------------
library(raster)
library(sf)
library(data.table)
library(foreach)

# get Virginia CDL Raster
r = raster("data/sdal_data/original/USDA_CDL/CDL_2014_51.tif")

library(cdlTools)

yr <- 2013

r = getCDL(51, yr, ssl.verifypeer = F)[[1]]
identical(r, cdlr[[1]])
# plot(r)

# get Virginia Block Group Shapefile
con <- sdalr::con_db("sdal")
sf <- st_read(con, c("geospatial$census_cb", "cb_2016_51_bg_500k"))
countyfp <- unique(sf[sf$STATEFP=="51", "COUNTYFP"]$COUNTYFP)
# sf_va <- sf[sf$STATEFP=="51",]
cdl_categories <- fread("data/sdal_data/original/USDA_CDL/usda_crop_data_layer_categories.csv")

# sf_va_bg <- sf[sf$STATEFP=="51" & sf$COUNTYFP=="013",]
# sf_va_tr <- sf[sf$STATEFP=="51" & sf$COUNTYFP=="013" & sf$TRACTCE=="100700",]
# sf_va <- sf[sf$STATEFP=="51" & sf$COUNTYFP=="013" & sf$TRACTCE=="100700" & sf$NAME=="3",]

# plot(sf_va)
# sp_va = as(st_geometry(sf_va), 'Spatial')
#
# p <- sp::spTransform(sp_va, crs(r))
# plot(r)
# lines(p)
#
# c <- crop(r, p)
# c2 <- mask(c, p)
# plot(c2)
# lines(p)
#
# sqm <- data.table::setDT(aggregate(getValues(area(c2, weights=FALSE)), by=list(getValues(c2)), sum))
# sqm[,.(Group.1, x, acres=x*0.00024711)]


acres_by_class <- function(raster_obj, sf_obj, cdl_cats) {
  for (i in 1:nrow(sf_obj)) {
    sf_row <- sf_obj[i,]
    sp_row <- as(st_geometry(sf_row), 'Spatial')
    sp_row <- spTransform(sp_row, crs(raster_obj))
    crp <- crop(raster_obj, sp_row)
    msk <- mask(crp, sp_row)
    sqm <- data.table::setDT(aggregate(getValues(area(msk, weights=FALSE)), by=list(getValues(msk)), sum))
    sqa <- sqm[,.(Group.1, x, acres=x*0.00024711)]
    sqa$geoid <- sf_row$GEOID

    if (exists("out_dt")) out_dt <- data.table::rbindlist(list(out_dt, sqa))
    else out_dt <- sqa
  }
  #browser()
  out_dt <- out_dt[,.(geoid, code=Group.1, acres)]
  out_dt <- merge(out_dt, cdl_cats, by = c("code"), all.x = T)
  out_dt
}

cl <- parallel::makeCluster(15, outfile = "")
doParallel::registerDoParallel(cl)

foreach (f=countyfp) %dopar% {
  library(raster)
  library(sf)
  library(data.table)
  print(paste("working on", f))
  . <- acres_by_class(r, sf[sf$STATEFP=="51" & sf$COUNTYFP==f,], cdl_categories)
  filename <- paste0("bg_acres_by_class_", f, "_2013.csv")
  fwrite(., file.path("data/sdal_data/working/usda_cdl", filename))
}

parallel::stopCluster(cl)



# acres_by_class_51121 <- acres_by_class(r, sf[sf$STATEFP=="51" & sf$COUNTYFP=="013",], cdl_categories)


library(cdlTools)
getCDL(51, 2014, ssl.verifypeer = F, location = "data/sdal_data/original/USDA_CDL/")

https://nassgeodata.gmu.edu/cdlservicedata/nass_data_cache/byfips/
