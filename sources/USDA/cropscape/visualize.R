# VISUALIZE

# FUNCTIONS ----------------------------------------------

# SCRIPT ----------------------------------------------
library(leaflet)
library(rmapshaper)
#* Get Geographies ----
#** Set geography filters ----
# select fips codes
dist_fips <- data.table::fread(input = "data/sdal_data/original/VCE/va_county_fips_extension_districts.csv",
                               colClasses = "character")
fips <- dist_fips[dist_fips$DISTRICT=="Southwest", "COUNTYFP"]
fips_list <- paste0("'", fips$COUNTYFP, "'", collapse = ",")

#** load county geographies
ct <- sf::st_read(sdalr::con_db("sdal"), query = "select *
                     from geospatial$census_tl.tl_2017_us_county
                     where \"STATEFP\" = '51'")[, c("COUNTYFP", "NAMELSAD")]
ct <- ct[ct$COUNTYFP %in% fips$COUNTYFP,]
ct <- sf::st_transform(ct, 4326)
ct <- ms_simplify(ct)

#** load block group geographies ----
bg <-
  sf::st_read(
    sdalr::con_db("sdal"),
    query = paste0(
      "SELECT * FROM geospatial$census_cb.cb_2016_51_bg_500k WHERE \"COUNTYFP\" IN (", fips_list, ")"
    )
  )
bg <- sf::st_transform(bg, 4326)
bg <- ms_simplify(bg)

#** add county names to block group geographies ----
ct_data <- ct
ct_data$geometry <- NULL
bg_ct_names <- merge(bg, ct_data, by = "COUNTYFP")


#* Get Associated Data ----
fips5 <- paste0("'", "51", fips$COUNTYFP, "'", collapse = ",")
fips_data <- data.table::setDT(DBI::dbGetQuery(sdalr::con_db("sdal"), paste0("SELECT *
                                                            FROM agriculture.va_bg_cropland_data_layer_10_17
                                                            WHERE LEFT(item_geoid, 5) IN (", fips5, ")")))
#** cast for mutliple item columns ----
fips_data_cst <- data.table::dcast(fips_data, item_geoid + item_year + item_measure ~ item_description, value.var = "item_value", fun=sum)
# fix names
names(fips_data_cst) <- tolower(gsub("/", "_", gsub(" +", "_", names(fips_data_cst))))


#* Merge Geographies and Associated Data ----
bg_data <- merge(bg_ct_names, fips_data_cst, by.x="GEOID", by.y="item_geoid", all.x = T)


map_sf <- bg_data[bg_data$item_year == "2010", ]

snap <- sf::st_read(sdalr::con_db("sdal"), query = paste0("select * from apps$dashboard.va_pl_snap_providers WHERE LEFT(item_geoid, 5) IN (", fips5, ")"))

mines <- sf::st_read(sdalr::con_db("sdal"), query = paste0("select * from apps$dashboard.va_pl_mining_operations WHERE LEFT(item_geoid, 5) IN (", fips5, ")"))

#* Create color pallette ----
pal <- leaflet::colorBin(
  palette = "Greens",
  domain = 0:2000,
  bins = c(0, 1, 10, 100, 1000, 5000, 10000, 100000),
  na.color = "#808080"
)

#* Set map items
crops <-
    c(
      "corn",
      "soybeans",
      "apples",
      "christmas_trees",
      "grass_pasture",
      "fallow_idle_cropland",
      "deciduous_forest",
      "evergreen_forest"
    )

#* Create map ----
m <- leaflet::leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addMapPane("base_layers", zIndex = 410) %>%
  addMapPane("boundaries", zIndex = 420) %>%
  addMapPane("places", zIndex = 430)

#* Create Map Layers ----
for (c in crops) {
  # create geo item labels
  labels <- lapply(
    paste("<strong>", map_sf$NAMELSAD, "</strong><br />",
          "tract:", substr(map_sf$GEOID, 6, 11), "<br />",
          "block group:", substr(map_sf$GEOID, 12, 12), "<br />",
          "crop:", c, "<br />",
          "measure:", map_sf$item_measure, "<br />",
          "value:", round(map_sf[, c][[1]], 2)
    ),
    htmltools::HTML
  )

  # block groups
  m <- addPolygons(m,
                data = map_sf,
                weight = 1,
                color = "Silver",
                fillOpacity = .6,
                fillColor = ~ pal(get(c)),
                label = labels,
                group = c,
                options = pathOptions(pane = "base_layers")
    )
}

# county lines
m <- addPolylines(m,
                  data = ct,
                  weight = 1.5,
                  color = "Black",
                  opacity = 1,
                  group = "county borders",
                  options = pathOptions(pane = "boundaries")
)



# m <- addCircleMarkers(m, color = "Yellow",
#                       data = snap,
#                       popup = ~ as.character(item_description),
#                       label = ~ as.character(item_name),
#                       radius = 6,
#                       clusterOptions = markerClusterOptions(iconCreateFunction =
#                                                               JS("
#                                           function(cluster) {
#                                              return new L.DivIcon({
#                                                html: '<div style=\"background-color:rgba(255,255,0,0.5)\"><span>' + cluster.getChildCount() + '</div><span>',
#                                                className: 'marker-cluster'
#                                              });
#                                            }")),
#                       group = "SNAP Providers (Yellow)",
#                       options = pathOptions(pane = "places")
# )

m <- addCircleMarkers(m, color = "Red",
                      data = mines,
                      popup = ~ as.character(item_description),
                      label = ~ as.character(item_name),
                      radius = 1,
                      # clusterOptions = markerClusterOptions(iconCreateFunction =
                      #                                         JS("
                      #                     function(cluster) {
                      #                        return new L.DivIcon({
                      #                          html: '<div style=\"background-color:rgba(77,77,77,0.5)\"><span>' + cluster.getChildCount() + '</div><span>',
                      #                          className: 'marker-cluster'
                      #                        });
                      #                      }")),
                      group = "Mines (Red)",
                      options = pathOptions(pane = "places")
)

#* Create Map Legend and Layers Control
m <- addLegend(m,
               data = map_sf,
               position = "topleft",
               pal = pal,
               values = 0:100000,
               title = "Acres",
               opacity = 1
               ) %>%
addLayersControl(baseGroups = crops,
                 overlayGroups = c("county borders", "Mines (Red)"),
                 # "SNAP Providers (Yellow)",
                 options = layersControlOptions(collapsed = FALSE)
                 )
m
