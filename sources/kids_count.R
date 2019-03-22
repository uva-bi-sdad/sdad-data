## Kid's Count Virginia

# Load Support Functions
source("functions/get_kidscount.R")
source("functions/db_names.R")
source("functions/data_info.R")

# Load data set info
data_info <-data.table::fread("sources/kids_count.csv")

# For each set of data set info
for (i in 1:nrow(data_info)) {
  # Get Data
  data_table <-
    get_kidscount(
      url = data_info[i, url],
      title = data_info[i, title],
      data_source = data_info[i, data_source],
      data_source_abrev = data_info[i, data_source_abrev],
      category = data_info[i, category],
      sub_category = data_info[i, sub_category],
      by = data_info[i, by],
      definitions = data_info[i, definitions]
    )

  # Create Schema and Table Names
  schema_name <-
    gsub("-", "", gsub(" +", "_", gsub("&", "", tolower(paste0(
      data_info[i, category], "$", data_info[i, sub_category]
    )))))
  table_name <-
    make_db_table_name(
      paste(
        data_info[i, containing_geo_name],
        data_info[i, containing_sub_geo_name],
        data_info[i, geo_type],
        paste(data_info[i, title], min(data_table$YEAR), max(data_table$YEAR))
      )
    )

  # Write Data to Database
  con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
  DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", schema_name))
  DBI::dbWriteTable(con, c(schema_name, table_name), data_table, row.names = F, overwrite = T)
}
