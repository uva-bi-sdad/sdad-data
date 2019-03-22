## CENSUS GeoSpatial Files Virginia

# Load Support Functions
R.utils::sourceDirectory("functions")

# Load data source info
data_info <- data.table::fread("sources/census/census_geospatial_files.csv")

# For each data_info record
for (i in 1:nrow(data_info)) {

  pg <- xml2::read_html(data_info[i, url])
  links <- rvest::html_attr(rvest::html_nodes(pg, "a"), "href")
  ziplinks <- stringr::str_subset(links, ".*zip")

  # Download Each Zip and Upload to DB
  for (l in ziplinks) {
    url <- paste0(data_info[i, url], l)
    schemaname <- data_info[i, schemaname]
    files <- dataplumbr::file_download_unzip2temp(url)
    shpfilepath <- files[grep("\\.shp$", files)[1]]
    shpfilebase <- stringr::str_match(basename(shpfilepath), "(.*)\\.shp")[,2]
    con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
    DBI::dbGetQuery(con, sprintf("CREATE SCHEMA IF NOT EXISTS %s", schemaname))
    sf::st_write_db(con,
                    sf::st_read(shpfilepath),
                    table = c(schemaname, tolower(shpfilebase)),
                    row.names = FALSE,
                    drop = TRUE)
  }
}
