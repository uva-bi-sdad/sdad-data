
# Load data source info
data_info <- data.table::fread("sources/HIFLD.csv")

# For each set of data
for (i in 1:nrow(data_info)) {
  # Create schema if needed
  schemaname <- data_info[i]$schemaname
  #con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, db_user = , db_pass = )
  
  con <- DBI::dbConnect(
    drv = RPostgreSQL::PostgreSQL() ,
    dbname = "sdad",
    host = "localhost",
    port = 5433,
    user = Sys.getenv("db_userid"),
    password = Sys.getenv("db_pwd"))
  
  DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", schemaname))

  tablename <- paste0(schemaname, ".", data_info[i]$tablename)
  #DBI::dbSendQuery(con, paste("TRUNCATE TABLE", tablename))

  # # Get Data
  # sf::st_write_db(sdalr::con_db("sdal"),
  #                 sf::st_read(data_info[i]$url),
  #                 table = c(schemaname, data_info[i]$tablename),
  #                 row.names = FALSE,
  #                 drop = TRUE)

  sf::st_write(
    sf::st_read(data_info[i]$url),
    con,
    layer = c(schemaname, data_info[i]$tablename),
    row.names = FALSE,
    append = T
  )

}


