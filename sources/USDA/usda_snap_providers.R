## USDA Sources
library(magrittr)
source("functions/latlong2county.R")

# U.S. Snap Retailer Locations
# Download and unzip to temp dir
url <- "https://fnssnaphal-gis.esriemcs.com/snap/export/Nationwide.zip"
files <- dataplumbr::file_download_unzip2temp(url)

# Get Date Parts From Filename
date_parts <- stringr::str_match(files[1], "(\\d\\d\\d\\d)_(\\d\\d)_(\\d\\d)")

dt_sf <-
  # Load File
  data.table::fread(files[1]) %>%
  # Add Source and Source Date
  .[, source := "USDA Food & Nutrition Service"] %>%
  .[, sourcedate := ISOdatetime(date_parts[2], date_parts[3], date_parts[4], 0, 0, 0)] %>%
  # Add a serial id column
  .[, id := seq(1:nrow(.))] %>%
  # Conver Lat and Lon to SF
  sf::st_as_sf(., coords = c("Longitude", "Latitude"), crs = 4326, agr = "constant")

# . <- data.table::fread(files[1])
# # Add Source and Source Date
# . <- .[, source := "USDA Food & Nutrition Service"]
# . <- .[, sourcedate := ISOdatetime(date_parts[2], date_parts[3], date_parts[4], 0, 0, 0)]
#
# # Conver Lat and Lon to SF
# dt_sf <- sf::st_as_sf(., coords = c("Longitude", "Latitude"), crs = 4326, agr = "constant")
# dt_sf$id <- seq(1:nrow(dt_sf))

# Add FIPS Columns
crds <- data.frame(dt_sf$id, sf::st_coordinates(dt_sf))
names(crds) <- c("id", "longitude", "latitude")
cntys <- latlong2county(crds$id, crds[c("longitude", "latitude")], 51)
dt_sf_cntys <- merge(dt_sf, cntys, by = "id")

# Create Schema if Needed
schemaname <- "geospatial$places"
con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", schemaname))

tablename <- paste0(schemaname, ".us_pl_snap_providers")
DBI::dbGetQuery(con, paste("TRUNCATE TABLE", tablename))

# # Upload to DB
# sf::st_write_db(
#   sdalr::con_db("sdal"),
#   dt_sf,
#   table = c(schemaname, "us_pl_snap_providers"),
#   geom_name = "wkb_geometry",
#   row.names = FALSE,
#   append = T
# )

sf::st_write(
  dt_sf_cntys,
  con,
  layer = c(schemaname, "us_pl_snap_providers"),
  row.names = FALSE,
  append = T
)
