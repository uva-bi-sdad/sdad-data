
# Create metadata.table_sets
recreate_metadata_data_sets <- function() {
  sql <-
"CREATE TABLE metadata.data_sets
(
  data_set_id serial PRIMARY KEY UNIQUE,
  data_set_source varchar(200),
  data_set_name varchar(200) UNIQUE,
  data_table_name varchar(100),
  data_set_url varchar(1000),
  data_set_description text,
  data_set_notes text,
  data_set_last_update date,
  data_set_category varchar(50),
  data_set_sub_category varchar(50),
  data_set_keywords varchar(500),
  data_set_license text
)"
  con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
  DBI::dbGetQuery(con, "CREATE SCHEMA IF NOT EXISTS metadata")
  DBI::dbGetQuery(con, "DROP TABLE IF EXISTS metadata.data_sets")
  DBI::dbGetQuery(con, "CREATE SCHEMA IF NOT EXISTS metadata")
  DBI::dbGetQuery(con, sql)
}

# Add data set info to metadata.table_sets
# data_set_geo_level = bg census block group, tr census tract, ct county or city,
#   st state, pl place, sd school district, fd fire district, pd police district
# data_set_geo_scope = us United States, va Virginia, arlington
data_set_metadata <- function(data_set_source,
                     data_set_name,
                     data_table_name,
                     data_set_url = "",
                     data_set_description = "",
                     data_set_notes = "",
                     data_set_last_update = "",
                     data_set_category = "",
                     data_set_sub_category = "",
                     data_set_keywords = "",
                     data_set_license=""
                     ) {
   df <- data.frame(
    data_set_source = data_set_source,
    data_set_name = data_set_name,
    data_table_name = data_table_name,
    data_set_url = data_set_url,
    data_set_description = data_set_description,
    data_set_notes = data_set_notes,
    data_set_last_update = as.Date(as.POSIXlt(Sys.time())),
    data_set_category = data_set_category,
    data_set_sub_category = data_set_sub_category,
    data_set_keywords = data_set_keywords,
    data_set_license = data_set_license
  )
   browser()
  DBI::dbWriteTable(sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2"), c("metadata", "data_sets"), df, append = T, row.names = F)
  DBI::dbGetQuery(sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2"), "SELECT MAX(data_set_id) AS data_set_id FROM metadata.data_sets")[[1]]
}


# #Create and Assign sdal tidy data column names
# sdal_dataset_tidy <- function(data_set,
#                               data_set_id,
#                               item_name_col,
#                               item_description_col = "",
#                               item_year_col = "",
#                               item_last_update_col = "",
#                               item_by = "",
#                               item_by_measure = "",
#                               item_measure_col = "",
#                               item_value_col,
#                               item_notes_col = "",
#                               item_state_fips_col = "",
#                               item_sub_state_fips_col = "",
#                               item_valid_use_begin_date_col = "",
#                               item_valid_use_end_date_col = "",
#                               item_valid_date_min_col = "",
#                               item_valid_date_max_col = "",
#                               item_valid_num_min_col = "",
#                               item_valid_num_max_col = "",
#                               item_valid_values_col = "") {
#   data.table::setDT(data_set)
#   data_set[, data_set_id := data_set_id]
#   . <- colnames(data_set)
#
#   l <- formals(sdal_dataset_tidy)
#   for (i in 3:length(l)) {
#     if (get(names(l[i])) != "") {
#       pattern <- get(names(l[i]))
#       replacement <- names(l[i])
#       . <- stringr::str_replace(., pattern, replacement)
#     } else {
#       . <- c(., names(l[i]))
#       data_set[, names(l[i]) := ""]
#     }
#   }
#
#   . <- tolower(.)
#   . <- stringr::str_replace_all(., "_col", "")
#   . <- dataplumbr::make_names(.)
#   colnames(data_set) <- .
#   data_set
# }
#
#
# #Example
# #Ag Data
# test_data <- readRDS("data/agriculture.us_ct_nass_qs_demographics_20180410.RDS")
#
# data_set_id <- data_set_metadata(
#   data_set_source = "United States Department of Agriculture, National Agricultural Statistics Service",
#   data_set_name = "NASS Demographics 2",
#   data_set_url = "ftp://ftp.nass.usda.gov/quickstats/",
#   data_set_description = "",
#   data_set_notes = "",
#   data_set_last_update = "",
#   data_set_category = "",
#   data_set_sub_category = "",
#   data_set_keywords = "",
#   data_set_geo_level = "",
#   data_set_geo_scope = ""
# )
#
# tdy_set <- sdal_dataset_tidy(test_data,
#                              data_set_id = data_set_id,
#                               item_name_col = "COMMODITY_DESC",
#                               item_description_col = "SHORT_DESC",
#                               item_year_col = "YEAR",
#                               item_last_update_col = "LOAD_TIME",
#                               item_measure_col = "UNIT_DESC",
#                               item_value_col = "VALUE",
#                               item_state_fips_col = "STATE_ANSI",
#                               item_sub_state_fips_col = "COUNTY_ANSI")
#
#
