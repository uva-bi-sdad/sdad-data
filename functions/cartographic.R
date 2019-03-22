## Upload Zipped Cartographic Files to PostGIS
# Functions
shpzip2db <- function(zipfilepath, dbname, schema) {
  tempdir <- dataplumbr::file.unzip2temp(zipfilepath)
  shpfile <- dataplumbr::file.findByType(tempdir, "shp", first_only = TRUE)
  shpfilepath <- file.path(tempdir, shpfile)
  shpfilebase <- stringr::str_match(basename(shpfilepath), "(.*)\\.shp")[,2]
  sf::st_write_db(sdalr::con_db(dbname), sf::st_read(shpfilepath), table = c(schema, tolower(shpfilebase)), row.names = FALSE, drop = TRUE)
  unlink(tempdir, recursive = TRUE)
}
shpzips2db <- function(dbname, schema, zipfiledir) {
  zipfiles <- dataplumbr::file.findByType(zipfiledir, "zip", full_path = TRUE)
  mapply(shpzip2db, zipfiles, dbname, schema)
}