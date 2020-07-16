library(jsonlite)
library(data.table)

#' Convert FCC location to FIPS code
#'
#' @param place_id some unique identifier for the lat lon
#' @param lat the latitude
#' @param lon the longitude
#' @return data.table
#' @export
#' @examples
#' FCClocation2FIPS("VTRC", lat=38.880807, lon=-77.11577)
FCClocation2FIPS <- function(place_id, lat, lon) {
  json_string <- sprintf('https://geo.fcc.gov/api/census/area?lat=%s&lon=%s&format=json',
                           lat, lon)
    if (length(place_id) > 1) {stop('you supplied multiple values for place_id, did you mean to use FCClocations2FIPS?')}
    if (length(lat) > 1) {stop('you supplied multiple values for lat, did you mean to use FCClocations2FIPS?')}
    if (length(lon) > 1) {stop('you supplied multiple values for lon, did you mean to use FCClocations2FIPS?')}

    res <- jsonlite::fromJSON(json_string)
    res$results
}

#' Convert multiple FCC locations to FIPS codes
#'
#' @param place_idCol vector of unique identifiers
#' @param latCol vector of latitudes
#' @param lonCol vector of longitudes
#' @return data.table
#' @export
#' @examples
#' FCClocations2FIPS(place_idCol = c("VTRC", "VT-NVC"),
#'                   latCol = c(38.880807, 38.8968325),
#'                   lonCol = c(-77.11577, -77.1894815))
FCClocations2FIPS <- function(place_idCol, latCol, lonCol) {
    data.table::as.data.table(t(mapply(FCClocation2FIPS, place_idCol, latCol, lonCol)))
}
