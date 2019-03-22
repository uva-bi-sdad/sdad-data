library("sf")
schemaname <- "geospatial$arlington_va"
tablename <- "arlington_va_voting_precincts"
con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
DBI::dbGetQuery(con, sprintf("CREATE SCHEMA IF NOT EXISTS %s", schemaname))
sf::st_write_db(con,
                sf::st_read("https://opendata.arcgis.com/datasets/ed2ad0e722514df9b27e398c621b2755_0.geojson"),
                table = c(schemaname, tablename),
                row.names = FALSE,
                drop = TRUE)
