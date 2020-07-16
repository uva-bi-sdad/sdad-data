bg_sf <-
  sf::st_read(
    sdalr::con_db("sdal"),
    query = paste0(
      "SELECT * FROM geospatial$census_cb.cb_2016_51_bg_500k WHERE \"COUNTYFP\" = '013'"
    )
  )

pts <- data.table::fread("../dashboard_tutorial/crime data.csv")
pts_sf <- sf::st_as_sf(pts, coords = c("longitude", "latitude"))
sf::st_crs(pts_sf) <- sf::st_crs(bg_sf)

bg_pts_sf <- sf::st_join(pts_sf, bg_sf, join = st_intersects)
