
# Load data source info
data_info <- data.table::fread("sources/HIFLD.csv")

# For each set of data
for (i in 1:nrow(data_info)) {
  # Create schema if needed
  schemaname <- data_info[i]$schemaname
  con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
  DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", schemaname))

  tablename <- paste0(schemaname, ".", data_info[i]$tablename)
  DBI::dbGetQuery(con, paste("TRUNCATE TABLE", tablename))

  # # Get Data
  # sf::st_write_db(sdalr::con_db("sdal"),
  #                 sf::st_read(data_info[i]$url),
  #                 table = c(schemaname, data_info[i]$tablename),
  #                 row.names = FALSE,
  #                 drop = TRUE)

  sf::st_write(
    sf::st_read(data_info[i]$url),
    sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2"),
    layer = c(schemaname, data_info[i]$tablename),
    row.names = FALSE,
    append = T
  )

}


