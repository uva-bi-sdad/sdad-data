## Read Geospatial File from DB and Plot
# create db connection
con <- sdalr::con_db("sdal")
# read shape from db
gs <- sf::st_read_db(con, c("geospatial$census_cb", "cb_2016_51_county_within_ua_500k"))
# limit to Arlington
gs <- gs[gs$COUNTYFP10=="013",]
# add in the police call locations
DT <- data.table(latitude = c(38.91058, 38.89512, 38.85228, 38.89512, 38.84480, 38.84480, 38.84705,
                              38.84788, 38.86379, 38.87954, 38.85526, 38.88854),
                 longitude = c(-77.13967, -77.07277, -77.05204, -77.07277, -77.09586, -77.09586,
                               -77.07739, -77.08898, -77.07867, -77.10520, -77.11541, -77.14661))
# convert to sf object
DT_sf = st_as_sf(DT, 
                 coords = c("longitude", "latitude"), 
                 crs = sf::st_crs(gs), 
                 agr = "constant")
# plot
plot(sf::st_geometry(gs), axes = TRUE, graticule = TRUE)
plot(sf::st_geometry(DT_sf), axes = TRUE, col = "blue", add = TRUE)


