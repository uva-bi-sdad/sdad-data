library(sp)
library(maps)
library(maptools)

#' Return a county for a data.frame of lat lon values

#' @param pointsdF data.frame in which:
#' column 1 contains the longitude in degrees (negative in the US) AND
#' column 2 contains the latitude in degrees
#'
#' @export
latlong2county <- function(ids, pointsDF, state_FIPS) {
    state_counties <- tigris::block_groups(state = state_FIPS)
    pointsDF_sp <- SpatialPoints(pointsDF)
    proj4string(pointsDF_sp) <- proj4string(state_counties)
    indices <- over(pointsDF_sp, state_counties)
    data.frame(id = ids, geoid = indices$GEOID)
}
