
# Function to get Webpage URLS ----------------------------------------------

get_spotcrime_urls <- function(url, pattern, prefix = "") {
  print(url)
  if (prefix == "") prefix = url
  . <- xml2::read_html(url)
  . <- rvest::html_nodes(., 'a')
  . <- rvest::html_attr(., 'href')
  . <- stringr::str_match(., pattern)[,2]
  . <- .[!is.na(.)]
  . <- paste0(prefix, .)
}


# Function to Parse a Webpage for Information Items ----------------------------------------------

get_spotcrime_details <- function(url) {
  print(url)
  #browser()
  crime_details <- xml2::read_html(url)
  if (exists("crime_details")) {
    crime_type <- rvest::html_text(rvest::html_nodes(crime_details, 'dd'))[1]
    crime_date <- rvest::html_text(rvest::html_nodes(crime_details, 'dd'))[2]
    crime_data_source <- rvest::html_attr(rvest::html_nodes(rvest::html_nodes(crime_details, 'dd'), 'a'), 'href')
    crime_description <- rvest::html_text(rvest::html_nodes(crime_details, xpath = '//*[@itemprop="description"]'))
    crime_address <- rvest::html_text(rvest::html_nodes(crime_details, xpath = '//*[@itemprop="street-address"]'))
    crime_latitude <- rvest::html_attr(rvest::html_nodes(crime_details, xpath = '//*[@itemprop="latitude"]'), 'content')
    crime_longitude <- rvest::html_attr(rvest::html_nodes(crime_details, xpath = '//*[@itemprop="longitude"]'), 'content')

    crime_details_dt <- data.table::data.table(crime_description,
                                               crime_type,
                                               crime_date,
                                               crime_address,
                                               crime_data_source,
                                               crime_latitude,
                                               crime_longitude)
  } else {
    crime_details_dt <- data.table::data.table(crime_description=character(),
                                               crime_type=character(),
                                               crime_date=character(),
                                               crime_address=character(),
                                               crime_data_source=character(),
                                               crime_latitude=character(),
                                               crime_longitude=character())
  }
  crime_details_dt
}


# Get Daily Crime Report Page URLS for Virginia ----------------------------------------------

. <- get_spotcrime_urls(url = "https://spotcrime.com/va/",
                        pattern = "/va/(.*daily$)")
.
# limit urls to Arlington for testing
. <- stringr::str_match(., "(.*arlington.*)")[,2]
. <- .[!is.na(.)]

saveRDS(., "sources/spotcrime/daily_crime_report_virginia_urls_arl.RDS")



# Get Daily Crime Report URLS for Each Locality in Virginia  ----------------------------------------------

. <- readRDS("sources/spotcrime/daily_crime_report_virginia_urls_arl.RDS")

. <-
  lapply(
    .,
    get_spotcrime_urls,
    pattern = "/va/(.*-[0-9][0-9]$)",
    prefix = "https://spotcrime.com/va/"
  )
. <- unlist(.)
. <- .[. != "https://spotcrime.com/va/"]

saveRDS(., "sources/spotcrime/daily_crime_report_locality_urls_arl.RDS")



# Get Daily Crime Report Details URL for Each Crime in Each Locality in Virginia  ----------------------------------------------

. <- readRDS("sources/spotcrime/daily_crime_report_locality_urls_arl.RDS")

. <-
  lapply(
    .[1:20],
    get_spotcrime_urls,
    pattern = "/(mobile/crime/.*)",
    prefix = "https://spotcrime.com/"
  )
. <- unlist(.)
. <- .[. != "https://spotcrime.com/"]

saveRDS(., "sources/spotcrime/daily_crime_report_details_urls_arl.RDS")



# Get Daily Crime Report Details for Each Crime in Virginia  ----------------------------------------------

. <- readRDS("sources/spotcrime/daily_crime_report_details_urls_arl.RDS")
#. <- .[1:20]

cl <- parallel::makeCluster(15, outfile = "")
. <- parallel::parLapply(cl, ., get_spotcrime_details)
parallel::stopCluster(cl)

daily_crime_report_details_arl <- data.table::rbindlist(.)

saveRDS(daily_crime_report_details_arl, "sources/spotcrime/daily_crime_report_details_arl.RDS")


rds <- data.table::rbindlist(list(
  readRDS("sources/spotcrime/daily_crime_report_details_arl_061217_060918.RDS"),
  readRDS("sources/spotcrime/daily_crime_report_details_arl_010608_061117.RDS")
))
data.table::setnames(rds, "crime_date", "crime_date_time")

rds[nchar(crime_date_time) > 10, crime_date := lubridate::as_date(lubridate::mdy_hm(crime_date_time))]
rds[nchar(crime_date_time) > 10, crime_hour := lubridate::hour(lubridate::as_datetime(lubridate::mdy_hm(crime_date_time)))]
rds[nchar(crime_date_time) == 10, crime_date := lubridate::as_date(lubridate::mdy(crime_date_time))]
rds[nchar(crime_date_time) == 10, crime_hour := NA]
rds[, crime_year := lubridate::year(crime_date)]

rds[, longitude := as.numeric(crime_longitude)]
rds[, latitude := as.numeric(crime_latitude)]

rds_sf <- sf::st_as_sf(rds, coords = c("longitude", "latitude"))
sf::st_crs(rds_sf) <- 4326

sf::st_write(rds_sf, sdalr::con_db("sdal"), c("behavior", "va_pl_spotcrime_08_18"), overwrite = TRUE)

