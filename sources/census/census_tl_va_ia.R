f <- download.file("ftp://ftp2.census.gov/geo/tiger/TIGER2018/BG/tl_2018_51_bg.zip", "data/sdad_data/working/tl_2018_51_bg.zip")
unzip("data/sdad_data/working/tl_2018_51_bg.zip", exdir = "data/sdad_data/working/tl_2018_51_bg")

s <- sf::read_sf("data/sdad_data/working/tl_2018_51_bg/tl_2018_51_bg.shp")

con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
sf::st_write_db(con,
                sf::st_read("data/sdad_data/working/tl_2018_51_bg/tl_2018_51_bg.shp"),
                table = c("geospatial$census_tl", "tl_2018_51_bg"),
                row.names = FALSE,
                drop = TRUE)


f <- download.file("ftp://ftp2.census.gov/geo/tiger/TIGER2018/BG/tl_2018_19_bg.zip", "data/sdad_data/working/tl_2018_19_bg.zip")
unzip("data/sdad_data/working/tl_2018_19_bg.zip", exdir = "data/sdad_data/working/tl_2018_19_bg")

s <- sf::read_sf("data/sdad_data/working/tl_2018_19_bg/tl_2018_19_bg.shp")

con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
sf::st_write_db(con,
                sf::st_read("data/sdad_data/working/tl_2018_19_bg/tl_2018_19_bg.shp"),
                table = c("geospatial$census_tl", "tl_2018_19_bg"),
                row.names = FALSE,
                drop = TRUE)


f <- download.file("ftp://ftp2.census.gov/geo/tiger/TIGER2018/TABBLOCK/tl_2018_51_tabblock10.zip", "data/sdad_data/working/tl_2018_51_tabblock10.zip")
unzip("data/sdad_data/working/tl_2018_51_tabblock10.zip", exdir = "data/sdad_data/working/tl_2018_51_tabblock10")

s <- sf::read_sf("data/sdad_data/original/CENSUS/tl_2018_51_tabblock10/tl_2018_51_tabblock10.shp")

con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
sf::st_write_db(con,
                sf::st_read("data/sdad_data/original/CENSUS/tl_2018_51_tabblock10/tl_2018_51_tabblock10.shp"),
                table = c("geospatial$census_tl", "tl_2018_51_tabblock10"),
                row.names = FALSE,
                drop = TRUE)


con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
sf::st_write_db(con,
                sf::st_read("data/sdad_data/original/CENSUS/tl_2018_19_tabblock10/tl_2018_19_tabblock10.shp"),
                table = c("geospatial$census_tl", "tl_2018_19_tabblock10"),
                row.names = FALSE,
                drop = TRUE)
