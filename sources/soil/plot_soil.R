library(leaflet)

# AQUIRE DATA
#* Load soil data
soilPI = readRDS("./data/sdal_data/working/soil/final.RDS")
soilPIdf <- as.data.frame(soilPI)
soilPIdf <- soilPIdf[,c("GEOID", "COUNTYFP", "combined_spi")]

#* Get block groups ----
con <- con_db("sdal")
#** load block group geometries ----
va_bg <- sf::st_read(con, c("geospatial$census_cb", "cb_2016_51_bg_500k"))
#** add county names ----
va_co_names <- DBI::dbGetQuery(con, "select \"COUNTYFP\", \"NAMELSAD\"
                            from geospatial$census_tl.tl_2017_us_county
                            where \"STATEFP\" = '51'")
va_bg_co_names <- merge(va_bg, va_co_names, by = "COUNTYFP")


#* Get county fips codes and names ----
dist_fips <- data.table::fread(input = "data/sdal_data/original/VCE/va_county_fips_extension_districts.csv",
                               colClasses = "character")
#* Filter counties ----
swva_fips <- dist_fips[dist_fips$DISTRICT=="Southwest", "COUNTYFP"]$COUNTYFP

#* Filter soil data to selected counties ----
soilPI_sw_va <- soilPIdf[soilPIdf$COUNTYFP %in% swva_fips,]
#* Filter block groups to selected counties ----
bg_sw_va <- va_bg_co_names[va_bg_co_names$COUNTYFP %in% swva_fips,]

#* Merge soil and block group, create spatial ----
soilPI_bg_sw_va <- merge(bg_sw_va, soilPI_sw_va, by = "GEOID")
soilPI_bg_sw_va_sf <- sf::st_as_sf(soilPI_bg_sw_va)

plot(soilPI_bg_sw_va_sf[, c("ALAND")])

#* Create color pallette function ----
pal <- leaflet::colorNumeric(
  palette = "viridis",
  domain =soilPI_bg_sw_va_sf$combined_spi)

#* Create labels
labels <- lapply(paste(soilPI_bg_sw_va_sf$NAMELSAD,
                       "<br />bg:",
                       soilPI_bg_sw_va_sf$GEOID,
                       "<br />combined spi:",
                       round(soilPI_bg_sw_va_sf$combined_spi, 2)),
                 htmltools::HTML)

#* Create map ----
leaflet::leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = soilPI_bg_sw_va_sf,
              stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = 1,
              color = ~pal(combined_spi),
              label = labels)






library(data.table)
m_dt <- data.table::setDT(m)
arl <- m_dt[GEOID %like% "51013",]


plot(arl)

head(va)
soil = sf::st_join(bg, soilPI, by = "GEOID")

ggplot(va) +
  geom_polygon(aes(fill = soil$combined_spi, x = long,y = lat, alpha = 1)) +
  geom_sf(data = soil) +
# scale_color_manual(values = c("(-Inf, 20]" = "green",
#                               "(20, 40]" = "lightblue",
#                               "(40, Inf]" = "red"))

soilPI$longitude = seal_coords$lon
soilPI$latitude = seal_coords$lat

seal_coords <- do.call(rbind, st_geometry(soilPI$geometry)) %>%
  as_tibble() %>% setNames(c("lon","lat"))
