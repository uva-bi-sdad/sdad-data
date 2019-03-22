library("tidytransit")
library("ggplot2")
library("data.table")
library("sf")
source("functions/get_bg_gravity.R")
source("functions/theme_map.R")

feed_url <- feedlist_df %>%
  setDT(.) %>%
  .[loc_t %like% "Marshalltown, IA", url_i]

# read gtfs data from url
gtfs <- read_gtfs(feed_url, geometry = TRUE, frequency = TRUE)

stop_departures_sf <-
  setDT(gtfs$stops_frequency) %>%
  # sum departures by stop_id
  .[, .(departs=sum(departures)), stop_id] %>%
  merge(., gtfs$stops_sf, by = "stop_id", all.x = TRUE) %>%
  st_as_sf() %>%
  st_transform(crs = 4269) %>%
  .[, c("stop_id", "departs", "stop_name", "geometry")]

con <- sdalr::con_db(dbname = "sdad", host = "127.0.0.1", port = 5433, user = "anonymous", pass = "anonymous")

# get census blocks
sql <- "SELECT distinct \"GEOID10\" geoid, geometry
        FROM tl_2018_19_tabblock10 where left(\"GEOID10\", 5) = '19127'"
marshall_county_blocks <- sf::st_read(con, query = sql) %>%
  st_transform(crs = 4269)

# get census block groups
sql <- "SELECT distinct \"GEOID\" geoid, geometry
        FROM tl_2018_19_bg where left(\"GEOID\", 5) = '19127'"
bg_geos <- sf::st_read(con, query = sql)

# exclude certain block groups
excld <- c("191279501004","191279502002","191279502003","191279502001","191279503002","191279503003","191279503004","191279504004")
bg_geos <- bg_geos[!bg_geos$geoid %in% excld,]

stop_departures_block <- st_intersection(stop_departures_sf, marshall_county_blocks) %>%
  setDT() %>%
  .[, c("stop_id", "departs", "geoid")] %>%
  .[, .(tot_departs=sum(departs)), .(geoid)]

gravity_idx <- get_bg_gravity(bg_geos$geoid, stop_departures_block, block_geoid = "geoid")
gravity_idx[, bgidx_lg := log(bgidx)]
gravity_idx$bgidx_lg <- scale(gravity_idx$bgidx_lg,center=min(gravity_idx$bgidx_lg),scale=diff(range(gravity_idx$bgidx_lg)))

gravity_idx[, rank := cut(bgidx_lg,breaks=quantile(bgidx_lg,probs=seq(0,1,by=0.2)),labels=1:5,include.lowest=TRUE)]


tomap <- merge(gravity_idx, bg_geos, by = "geoid")

tomap_sf <- sf::st_as_sf(tomap)

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
EVI_palette<-cbPalette[c(6,3,1,5,7)]
EVI_palette<-cbPalette[c(7,5,1,3,6)]


p <- ggplot(data = tomap_sf) +
  theme_map() +
  geom_sf(aes(fill = rank), color = "grey20") +
  # scale_fill_viridis_c()
  theme(legend.position = "bottom") +
  scale_fill_manual(
    values = EVI_palette,
    name = "Transit Access Index Quantiles",
    drop = FALSE,
    labels = c("Low Access", "", "", "", "High Access"),
    guide = guide_legend(
      direction = "horizontal",
      keyheight = unit(2, units = "mm"),
      keywidth = unit(30 / length(labels), units = "mm"),
      title.position = 'top',
      title.hjust = 0.5,
      label.hjust = 1,
      nrow = 1,
      byrow = T,
      reverse = F,
      label.position = "bottom"
    )
  ) +
labs(
  x = NULL,
  y = NULL,
  title = "Transit Access Index Quantiles",
  subtitle = "Marshalltown, GTFS, 2018",
  caption = "Geometries: Census Block Groups, 2018")

p


# mtown_route_geo <- get_route_geometry(mtown)
# mtown_stop_geo <- mtown$stops_sf
#
#plot(mtown_stop_geo_tr)
mtown_stop_geo_tr <- st_transform(gtfs$stops_sf, 4269)

pp <- ggplot(data = tomap_sf) +
  theme_map() +
  geom_sf(aes(fill = rank), color = "grey20") +
  # scale_fill_viridis_c()
  theme(legend.position = "bottom") +
  scale_fill_manual(
    values = EVI_palette,
    name = "Transit Access Index Quantiles",
    drop = FALSE,
    labels = c("Low Access", "", "", "", "High Access"),
    guide = guide_legend(
      direction = "horizontal",
      keyheight = unit(2, units = "mm"),
      keywidth = unit(30 / length(labels), units = "mm"),
      title.position = 'top',
      title.hjust = 0.5,
      label.hjust = 1,
      nrow = 1,
      byrow = T,
      reverse = F,
      label.position = "bottom"
    )
  ) +
  geom_sf(data = mtown_stop_geo_tr) +
  labs(
    x = NULL,
    y = NULL,
    title = "Transit Access Index Quantiles",
    subtitle = "Marshalltown, GTFS, 2018",
    caption = "Geometries: Census Block Groups, 2018")

pp
#
# mtown$routes_frequency
#
#
#
#
# sfreq <- setDT(mtown$stops_frequency)
# sfreq[,min(headway)]
#
# stop_departures <- sfreq[, .(departs=sum(departures)), stop_id]
#
# stop_departures_sf <- st_as_sf(merge(stop_departures, mtown_stop_geo, by = "stop_id", all.x = TRUE))
# stop_departures_sf <- st_transform(stop_departures_sf, 4269)
# stop_departures_sf <- stop_departures_sf[, c("stop_id", "departs", "stop_name", "geometry")]

