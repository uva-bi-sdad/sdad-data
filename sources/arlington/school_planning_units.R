library("sf")
schemaname <- "geospatial$arlington_va"
tablename <- "arlington_va_school_planning_units"
con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
DBI::dbGetQuery(con, sprintf("CREATE SCHEMA IF NOT EXISTS %s", schemaname))
sf::st_write_db(con,
                sf::st_read("https://opendata.arcgis.com/datasets/dd324743b3d94ac4a27c09f18d1200cb_0.geojson"),
                table = c(schemaname, tablename),
                row.names = FALSE,
                drop = TRUE)


con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
DBI::dbGetQuery(con, sprintf("CREATE SCHEMA IF NOT EXISTS education"))
pu_data <- data.table::fread("data/sdad_data/original/Arlington/planning_unit_enroll_projection_oct_18.csv")
DBI::dbWriteTable(con, c("education", "planning_unit_enroll_projection_oct_18"), pu_data, row.names = F, overwrite = T)


con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
geo <- sf::st_read_db(con, c("geospatial$arlington_va", "arlington_va_school_planning_units"))
colnames(geo)[colnames(geo)=="PU"] <- "pu"
dat <- DBI::dbGetQuery(con, "select * from education.planning_unit_enroll_projection_oct_18")
geo_dat <- merge(geo, dat, by = "pu")

plot(geo_dat[,c("Hispanic")])
