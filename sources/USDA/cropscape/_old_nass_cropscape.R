# ACRES OF LAND USE TYPE FOR COUNTY BLOCK GROUPS ----------------------------------------------

# FUNCTIONS ----------------------------------------------
get_cdl_files <- function(states = c(51), years = c(2016), dir = "data/sdal_data/original/USDA_CDL/") {
  for (s in states) {
    for (y in years) {
      print(paste("getting", s, y))
      cdlTools::getCDL(s, y, ssl.verifypeer = F, location = dir)
    }
  }
  list.files(dir, full.names = T)
}

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



# AQUIRE DATA ----------------------------------------------

#* Download and save CDL files ----
get_cdl_files(states = c(51), years = c(2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017))



# CLEAN & TRANSFORM ----------------------------------------------

#* Get crop acres by type by block group ----
#** get list of cdl files ----
cdl_files <- list.files("data/sdal_data/original/USDA_CDL/", full.names = T, pattern = "*\\.tif$")
#** get polygons (Virginia block group spatial(sf) files) ----
con <- sdalr::con_db("sdal")
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
    data.table::fwrite(., file.path("data/sdal_data/working/usda_cdl", filename))
  }
}
#** return resources ----
parallel::stopCluster(cl)

#* Combine all data files, add year and description columns, save new file ----
data_files <- list.files("data/sdal_data/working/usda_cdl", full.names = T)
for (f in data_files) {
  yr <- stringr::str_match(f, "_(\\d\\d\\d\\d)")[,2]
  dt <- data.table::fread(f)
  dt$year <- yr
  if (exists("final_dt")) final_dt <- data.table::rbindlist(list(final_dt, dt))
  else final_dt <- dt
}
final_dt$desc <- cdlTools::updateNamesCDL(dt$class)
data.table::fwrite(final_dt, file.path("data/sdal_data/working/usda_cdl", "bg_acres_by_class_all.csv"))



# STORE DATA SET ----------------------------------------------

#* prepare data set metadata ----
ds_metadata <- data.table::data.table(
  data_set_source = "USDA National Agricultural Statistics Service (NASS) Cropland Data Layer",
  data_set_name = "Virginia Cropland Data Layer 2010 - 2017",
  data_table_name = "va_bg_cropland_data_layer_10_17",
  data_set_url = "",
  data_set_description = "Land coverage in acres by crop type by block group by year. Created using USDA NASS Cropland Data Layer by VT-SDAL July 2018.",
  data_set_last_update = "7/17/2018",
  data_set_category = "Agriculture",
  data_set_sub_category = "",
  data_set_keywords = "Agriculture, Crops, Acreage"
)

#* write metadata to db ----
DBI::dbWriteTable(sdalr::con_db("sdal"), c("metadata", "data_sets"), ds_metadata, append = T, row.names = F)

#* get new data set id ----
ds_id <- DBI::dbGetQuery(sdalr::con_db("sdal"), "SELECT MAX(data_set_id) AS data_set_id FROM metadata.data_sets")[[1]]

#* prepare data set ----
final_dt <- data.table::fread("data/sdal_data/working/usda_cdl/bg_acres_by_class_all.csv")

ds_data <- final_dt[, .(
  data_set_id = ds_id,
  item_geoid = geoid,
  item_name = class,
  item_description = desc,
  item_year = year,
  item_measure = "acre",
  item_value = acres
)]

#* set schema ----
ds_schema <-
  if (ds_metadata$data_set_sub_category != "") {
    paste0(ds_metadata$data_set_category, "$", ds_metadata$data_set_sub_category)
  } else {
    ds_metadata$data_set_category
  }

# check schema
DBI::dbGetQuery(sdalr::con_db("sdal"), paste0("CREATE SCHEMA IF NOT EXISTS ", ds_schema))

# write data set to db
DBI::dbWriteTable(sdalr::con_db("sdal"), c(ds_schema, ds_metadata$data_table_name), ds_data, append = T, row.names = F)



# VISUALIZE ----------------------------------------------

library(leaflet)
library(leaflet.minicharts)
#* Get block groups ----
con <- sdalr::con_db("sdal")
#** load block group geometries ----
va_bg <- sf::st_read(con, c("geospatial$census_cb", "cb_2016_51_bg_500k"))
#** add county names ----
va_co_names <- DBI::dbGetQuery(con, "select \"COUNTYFP\", \"NAMELSAD\"
                            from geospatial$census_tl.tl_2017_us_county
                            where \"STATEFP\" = '51'")
va_co <- sf::st_read(con, query = "select *
                                   from geospatial$census_tl.tl_2017_us_county
                                   where \"STATEFP\" = '51'")[, c("COUNTYFP", "NAMELSAD")]
va_co_names <- data.frame(COUNTYFP=va_co$COUNTYFP, NAMELSAD=va_co$NAMELSAD)


va_bg_co_names <- merge(va_bg, va_co_names, by = "COUNTYFP")

#* Get county fips codes and names ----
dist_fips <- data.table::fread(input = "data/sdal_data/original/VCE/va_county_fips_extension_districts.csv",
                               colClasses = "character")
#* Filter counties ----
swva_fips <- dist_fips[dist_fips$DISTRICT=="Southwest", "COUNTYFP"]$COUNTYFP

#* Filter block groups to selected counties ----
bg_sw_va <- va_bg_co_names[va_bg_co_names$COUNTYFP %in% swva_fips,]
#* Filter data to selected counties ----
swva_fips_va <- paste0("'", "51", swva_fips, "'", collapse = ",")
data_sw_va <- data.table::setDT(DBI::dbGetQuery(con, paste0("SELECT *
                                        FROM agriculture.va_bg_cropland_data_layer_10_17
                                        WHERE LEFT(item_geoid, 5) IN (", swva_fips_va, ")")))

swva_co <- va_co[va_co$COUNTYFP %in% swva_fips,]

dt2010corn <- data_sw_va[data_sw_va$item_year=="2010" & data_sw_va$item_name==1,]
dt2010soybean <- data_sw_va[data_sw_va$item_year=="2010" & data_sw_va$item_name==5,]

#data.table::dcast(dt2010, item_geoid + item_year ~ item_description, value.var = "item_value")

#* Merge spatial and data file ----
bg_sw_va_2010_corn <- merge(bg_sw_va, dt2010corn, by.x="GEOID", by.y="item_geoid", all.x = T)
bg_sw_va_2010_soybean <- merge(bg_sw_va, dt2010soybean, by.x="GEOID", by.y="item_geoid", all.x = T)

#* Create color pallette ----
pal_corn <- leaflet::colorBin(
  palette = "Greens",
  domain = bg_sw_va_2010_corn$item_value,
  bins = 9)

pal_soybean <- leaflet::colorBin(
  palette = "Greens",
  domain = bg_sw_va_2010_soybean$item_value,
  bins = 9)

#* Create labels
labels_corn <- lapply(paste(bg_sw_va_2010_corn$NAMELSAD,
                       "<br />bg:",
                       bg_sw_va_2010_corn$GEOID,
                       "<br />", bg_sw_va_2010_corn$item_measure,
                       round(bg_sw_va_2010_corn$item_value, 2)),
                 htmltools::HTML)

labels_soybean <- lapply(paste(bg_sw_va_2010_soybean$NAMELSAD,
                            "<br />bg:",
                            bg_sw_va_2010_soybean$GEOID,
                            "<br />", bg_sw_va_2010_soybean$item_measure,
                            round(bg_sw_va_2010_soybean$item_value, 2)),
                      htmltools::HTML)

#* Create map ----
m <- leaflet::leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = bg_sw_va_2010_corn, weight = 1, color = "Silver", fillOpacity = .3, fillColor = ~pal_corn(item_value),
              label = labels_corn, group = "corn") %>%
  addPolylines(data = swva_co, weight = 2.5, color = "Black", group = "corn") %>%
  addLegend(data = bg_sw_va_2010_corn, position = "topleft", pal = pal_corn, values = ~item_value,
            title = "Crop Acres Corn (2010)",
            opacity = 1, group = "corn") %>%
  addPolygons(data = bg_sw_va_2010_soybean, weight = 1, color = "Silver", fillOpacity = .3, fillColor = ~pal_soybean(item_value),
              label = labels_soybean, group = "soybean") %>%
  addPolylines(data = swva_co, weight = 1.5, color = "Black", group = "soybean") %>%
  addLegend(data = bg_sw_va_2010_soybean, position = "topleft", pal = pal_soybean, values = ~item_value,
            title = "Crop Acres Soybeans (2010)",
            opacity = 1, group = "soybean") %>%
  addLayersControl(
    overlayGroups = c("corn", "soybean"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  hideGroup("soybean")
m



corn_soybean_hay_17 <- data_sw_va[data_sw_va$item_name %in% c(1, 5, 37) & data_sw_va$item_year %in% c(2017),]
corn_soybean_hay_17_cast <- data.table::dcast(corn_soybean_hay_17, item_geoid + item_year + item_measure ~ item_description, value.var = "item_value")
corn_soybean_hay_17_cast_sf <- merge(bg_sw_va, corn_soybean_hay_17_cast, by.x="GEOID", by.y="item_geoid", all.x = T)
corn_soybean_hay_17_cast_sf_ctr <- sf::st_centroid(corn_soybean_hay_17_cast_sf)
lngs <- as.data.frame(sf::st_coordinates(corn_soybean_hay_17_cast_sf_ctr))$X
lats <- as.data.frame(sf::st_coordinates(corn_soybean_hay_17_cast_sf_ctr))$Y

addMinicharts(map = m,
  lng = lngs[640:645], lat = lats[640:645],
  type = "pie",
  chartdata = corn_soybean_hay_17_cast_sf_ctr[640:645, c("Corn", "Soybeans")],
  colorPalette = "Blues"
)
