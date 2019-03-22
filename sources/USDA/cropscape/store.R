# STORE DATA SET IN DB

# FUNCTIONS ----------------------------------------------

# SCRIPT ----------------------------------------------
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
    tolower(paste0(ds_metadata$data_set_category, "$", ds_metadata$data_set_sub_category))
  } else {
    tolower(ds_metadata$data_set_category)
  }

# check schema
DBI::dbGetQuery(sdalr::con_db("sdal"), paste0("CREATE SCHEMA IF NOT EXISTS ", ds_schema))

# write data set to db
DBI::dbWriteTable(sdalr::con_db("sdal"), c(ds_schema, ds_metadata$data_table_name), ds_data, append = F, row.names = F)
