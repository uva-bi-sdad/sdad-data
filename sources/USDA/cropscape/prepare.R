# PREPARE (CLEAN & TRANSFORM)

# FUNCTIONS ----------------------------------------------
crop_mask_raster_to_spatial <- function(raster_obj, sf_obj) {
  library(raster)
  library(sf)
  library(data.table)
  for (i in 1:nrow(sf_obj)) {
    sf_row <- sf_obj[i,]
    sp_row <- as(st_geometry(sf_row), 'Spatial')
    sp_row <- spTransform(sp_row, crs(raster_obj))
    crp <- crop(raster_obj, sp_row)
    msk <- mask(crp, sp_row)

    if (exists("out_ls") == F) out_ls <- list()
    out_ls[sf_row$GEOID] <- msk
  }
  out_ls
}

raster_sqm_to_acres <- function(raster_list) {
  for (i in 1:length(raster_list)) {
    sqm <- data.table::setDT(aggregate(getValues(area(raster_list[[i]], weights=FALSE)), by=list(getValues(raster_list[[i]])), sum))
    sqa <- sqm[,.(class = Group.1, sqm = x, acres = x*0.00024711)]
    sqa$geoid <- names(raster_list[i])
    if (exists("out_dt")) out_dt <- data.table::rbindlist(list(out_dt, sqa))
    else out_dt <- sqa
  }
  out_dt
}

# SCRIPT ----------------------------------------------
#* Get crop acres by type by block group ----
#** get list of cdl files ----
cdl_files <- list.files("data/sdad_data/original/USDA_CDL/", full.names = T, pattern = "*\\.tif$")
#** get polygons (Virginia block group spatial(sf) files) ----
con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
sf <- sf::st_read(con, c("geospatial$census_cb", "cb_2016_51_bg_500k"))
#** get list of county fips codes ----
countyfp <- unique(sf[sf$STATEFP=="51", "COUNTYFP"]$COUNTYFP)
#** create and register cluster for parallel processing ----
cl <- parallel::makeCluster(15, outfile = "")
doParallel::registerDoParallel(cl)
#** for each county, create file of crop acres by type by block group ----
library(foreach)
for (f in cdl_files) {
  print(paste("working with file:", f))
  r <- raster::raster(f)
  y <- stringr::str_match(f, "_(\\d\\d\\d\\d)")[,2]
  foreach::foreach (fp = countyfp) %dopar% {
    print(paste("working on fips code:", fp))
    . <- crop_mask_raster_to_spatial(r, sf[sf$STATEFP=="51" & sf$COUNTYFP==fp,])
    . <- raster_sqm_to_acres(.)
    filename <- paste0("bg_acres_by_class_", fp, "_", y, ".csv")
    data.table::fwrite(., file.path("data/sdad_data/working/usda_cdl", filename))
  }
}
#** return resources ----
parallel::stopCluster(cl)

#* Combine all data files, add year and description columns, save new file ----
data_files <- list.files("data/sdad_data/working/usda_cdl", full.names = T, pattern = ".*[0-9]\\.csv")
if (exists("final_dt") == T) rm(final_dt)
for (f in data_files) {
  yr <- stringr::str_match(f, "_(\\d\\d\\d\\d)")[,2]
  dt <- data.table::fread(f)
  dt$year <- yr
  if (exists("final_dt") == T) final_dt <- data.table::rbindlist(list(final_dt, dt))
  else final_dt <- dt
}
final_dt$desc <- cdlTools::updateNamesCDL(final_dt$class)
data.table::fwrite(final_dt, file.path("data/sdad_data/working/usda_cdl", "bg_acres_by_class_all.csv"))
