if (!require(soilDB)) install.packages('soilDB')
library(soilDB)
library(sp)
library(sf)
library(sdalr)
library(data.table)

source("R/store.R")

con <- con_db("sdal")
bg <- st_read(con, c("geospatial$census_cb", "cb_2016_51_bg_500k"))

st_centroid(bg)

colnames(bg)[colnames(bg)=="wkb_geometry"] <- "geometry"
st_geometry(bg) <- "geometry"

bg_coords <- bg %>%
  st_centroid

# store <- function(crd, crs =  CRS('+proj=longlat +datum=WGS84')) {
#   dt_out <- apply(X = crd, MARGIN = 1, FUN = function(row){
#         SpatialPoints(cbind(row[1], row[2]), proj4string = crs ) %>%
#           SDA_make_spatial_query() %>% as.data.table()
#     })
#   dt_out
# }


#DONT RUN THIS BLOCK, IT IS SAVED AS AN RDS OBJECT
#******************************************************************************
latlong_list = list()
for(i in 1:nrow(bg_coords)) {
  p <- SpatialPoints(st_coordinates(bg_coords[i,]), proj4string = CRS('+proj=longlat +datum=WGS84'))
  latlong_list[[i]] = SDA_make_spatial_query(p)
  if(i %% 100 == 0) print(paste("Finished iteration",i))
}

#handle NA
# for(i in 1:length(latlong_list)) {{
#     latlong_list = na.omit(latlong_list)
#   }
# }
nrow(bg_coords)

for(i in 1:length(latlong_list)) {
  if(is.na(latlong_list[i])) {
    latlong_list_1 =data.frame("mukey"=NA, "muname"=NA)
    latlong_list[[i]] = latlong_list_1
  }
}

latlong_table = rbindlist(latlong_list, fill = TRUE)

#mukey_merged = merge(bg_coords, latlong_table)
saveRDS(latlong_table, "./data/sdal_data/working/soil/mukey_per_latlong.RDS")

bg_coords$mukey = latlong_table$mukey
bg_coords$muname = latlong_table$muname
nrow(bg_coords)
nrow(latlong_table)
names(bg_coords)

mukey_per_latlong = bg_coords
saveRDS(mukey_per_latlong, "./data/sdal_data/working/soil/mukey_per_latlong.RDS")

#*********************************************************************************
latlong_table = readRDS("./data/sdal_data/working/soil/mukey_per_latlong.RDS")


latlong_list = list()
for(i in 3000:3100) {
  p <- SpatialPoints(st_coordinates(bg_coords[i,]), proj4string = CRS('+proj=longlat +datum=WGS84'))
  latlong_list[[i]] = SDA_make_spatial_query(p)
  if(i %% 100 == 0) print(paste("Finished iteration",i))
}

for(i in 1:length(latlong_list)) {
    if(is.na(latlong_list[i])) {
      latlong_list_1 =data.frame("mukey"=NA, "muname"=NA)
      latlong_list[[i]] = latlong_list_1
    }
}

latlong_table = rbindlist(latlong_list, fill = TRUE)

#test on one
t1 <- bg_coords[1:10,]
p <- SpatialPoints(st_coordinates(bg_coords[1:10,]), proj4string = CRS('+proj=longlat +datum=WGS84'))
latlong = SDA_make_spatial_query(p)


#test material
saveRDS(test_set, './data/sdal_data/working/soil/test_set.RDS')

# centroid = readRDS('./data/sdal_data/working/soil/mukey_bg_comb.RDS')
# u_centroid= unique(centroid$mukey) %>%
# data.table()


