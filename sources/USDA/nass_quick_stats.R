# Build National Agricultural Statistics Service - Quick Stats Data Sets ----------------------------------------------

# get file urls
ftp_url <- "ftp://ftp.nass.usda.gov/quickstats/"
ds_id <- "nass"
file_urls <-
  strsplit(RCurl::getURL(ftp_url, .opts = RCurl::curlOptions(ftplistonly = TRUE)), "\n")[[1]]
file_urls <- Filter(function(x) !any(grepl("sample", x)), file_urls)

# build parameters table
dataset_urls <-
  data.table::data.table(
    url = character(),
    filename = character(),
    destfile = character(),
    tablename = character()
  )
for (i in 1:length(file_urls)) {
  dt_url <- data.table::data.table(
    url = paste0(ftp_url, file_urls[i]),
    filename = file_urls[i],
    destfile = paste0("data/", file_urls[i]),
    tablename = paste0("us_ct_", ds_id, "_", gsub(
      ".", "_", gsub(
        ".txt",
        "",
        gsub(".gz", "", file_urls[i], fixed = TRUE),
        fixed = TRUE
      ), fixed = TRUE
    ))
  )
  dataset_urls <- data.table::rbindlist(list(dataset_urls, dt_url))
}

# get data files and upload to database
# for (u in 1:nrow(dataset_urls)) {
for (u in 2:nrow(dataset_urls)) {
  # Download and unzip to temp dir
  print(paste("Downloading, Decompressing and Reading", dataset_urls[u, destfile]))
  files <- dataplumbr::file.download_ungz2temp(dataset_urls[u, url])
  # Load File
  dt <- data.table::fread(files[1])
  dt <- dt[YEAR %in% seq(2008, 2017),]
  print(paste("Creating database table ", dataset_urls[u, tablename]))
  con <- sdalr::con_db("sdal")
  DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", "agriculture"))
  DBI::dbWriteTable(con, c("agriculture", dataset_urls[u, tablename]), dt, row.names = F, overwrite = T)
}



# source("functions/db.R")
# 
# sql <- gsub("[\r\n]", "", "
# SELECT \"COMMODITY_DESC\", \"STATE_ANSI\", \"COUNTY_ANSI\", \"COUNTY_NAME\", \"ASD_DESC\", \"VALUE\", \"ST_SUBST_FIPS\", \"CONTAINING_GEOID\", \"UNIT_DESC\" \"MEASURE\"
# FROM \"dt_nass_qs_crops_20170825\"
# WHERE \"STATE_FIPS_CODE\" = '51'
# AND \"YEAR\" = '2013'
# AND \"STATISTICCAT_DESC\" = 'PRODUCTION'
# AND \"COUNTY_ANSI\" IS NOT NULL
#  ORDER BY \"COMMODITY_DESC\"
# ")
# 
# nass <- data.table::setDT(DBI::dbGetQuery(get_con("dashboard"), sql))
# nass_sub <- nass[VALUE != "(D)",.(CONTAINING_GEOID, ST_SUBST_FIPS, COUNTY_NAME, COMMODITY_DESC, VALUE, MEASURE)]
# nass_sub[, VALUE := as.numeric(gsub(",", "", nass_sub$VALUE), na.rm = TRUE)]
# nass_cst <- data.table::dcast(nass_sub, CONTAINING_GEOID + ST_SUBST_FIPS + COUNTY_NAME ~ COMMODITY_DESC, value.var = "VALUE", fun.aggregate = mean)
# nass_cst[is.na(nass_cst)] <- 0
# 
# DBI::dbWriteTable(get_con("dashboard"), "dt_nass_qs_crops_production_2013", nass_cst, row.names = FALSE, overwrite = TRUE)


