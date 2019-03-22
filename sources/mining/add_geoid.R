source("functions/latlong2county.R")

dt_sf <- readRDS("data/sdal_data/working/mining/clean_mines_va_sf.RDS")
dt_sf$id <- seq(1:nrow(dt_sf))

# Add geoid column
crds <- data.frame(dt_sf$id, sf::st_coordinates(dt_sf))
names(crds) <- c("id", "longitude", "latitude")
cntys <- latlong2county(crds$id, crds[c("longitude", "latitude")], 51)
dt_sf_cntys <- merge(dt_sf, cntys, by = "id")

names(dt_sf_cntys) <- tolower(names(dt_sf_cntys))
for_db <- dt_sf_cntys[, c("mine_id",
                "current_mine_name",
                "mine_status",
                "current_mine_type",
                "primary_sic",
                "primary_canvass",
                "material",
                "no_employees",
                "geoid")]

names(for_db)[names(for_db) == 'mine_id'] <- 'item_id'
names(for_db)[names(for_db) == 'current_mine_name'] <- 'item_name'
names(for_db)[names(for_db) == 'geoid'] <- 'item_geoid'
names(for_db)[names(for_db) == 'current_mine_type'] <- 'item_type'
names(for_db)[names(for_db) == 'mine_status'] <- 'item_status'


#* prepare data set metadata ----
ds_metadata <- data.table::data.table(
  data_set_source = "MSHA Mining Operations",
  data_set_name = "MSHA Mining Operations 2017",
  data_table_name = "va_pl_mining_operations_17",
  data_set_url = "",
  data_set_description = "MSHA Mining Operations and Status",
  data_set_last_update = "7/17/2018",
  data_set_category = "geospatial",
  data_set_sub_category = "places",
  data_set_keywords = ""
)

#* write metadata to db ----
DBI::dbWriteTable(sdalr::con_db("sdal"), c("metadata", "data_sets"), ds_metadata, append = T, row.names = F)

#* get new data set id ----
ds_id <- DBI::dbGetQuery(sdalr::con_db("sdal"), "SELECT MAX(data_set_id) AS data_set_id FROM metadata.data_sets")[[1]]

for_db$data_set_id <- ds_id

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
DBI::dbWriteTable(sdalr::con_db("sdal"), c(ds_schema, ds_metadata$data_table_name), for_db, append = F, row.names = F)
