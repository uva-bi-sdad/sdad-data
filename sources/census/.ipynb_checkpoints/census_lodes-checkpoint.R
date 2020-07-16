library(data.table)
library(ggplot2)
library(sf)
source("functions/get_lodes.R")
source("functions/get_bg_gravity.R")
source("functions/theme_map.R")

con <- sdalr::con_db(dbname = "sdad", host = "127.0.0.1", port = 5433, user = "anonymous", pass = "anonymous")

# get census block group geographies
sql <- "SELECT distinct \"GEOID\" geoid, geometry
        FROM tl_2018_19_bg where left(\"GEOID\", 5) = '19127'"
bg_geos <- sf::st_read(con, query = sql)

# exclude certain block groups
excld <- c("191279501004","191279502002","191279502003","191279502001","191279503002","191279503003","191279503004","191279504004")
bg_geos <- bg_geos[!bg_geos$geoid %in% excld,]

# Get LODES job count data
lodes_ia_2015 <- data.table::setDT(read_lodes("ia", "od", "aux", "JT00", "2015", "data/sdad_data/original/CENSUS/LODES"))
lodes_ia_2015[, w_geocode := as.character(w_geocode)]

# get gravity indexes by block group
gravity_idx <- get_bg_gravity(bg_geos$geoid, block_counts_df = lodes_ia_2015, block_geoid = "w_geocode", block_cnt = "S000")
gravity_idx[, bgidx_lg := log(bgidx)]
gravity_idx$bgidx_lg <- scale(gravity_idx$bgidx_lg,center=min(gravity_idx$bgidx_lg),scale=diff(range(gravity_idx$bgidx_lg)))

gravity_idx[, rank := cut(bgidx_lg,breaks=quantile(bgidx_lg,probs=seq(0,1,by=0.2)),labels=1:5,include.lowest=TRUE)]

# merge gravity indexes with block group geographies
tomap <- merge(gravity_idx, bg_geos, by = "geoid")
# convert to sf
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
    name = "Employment Access Index Quantiles",
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
    title = "Employment Access Index Quantiles",
    subtitle = "Marshalltown, Census LODES, 2015",
    caption = "Geometries: Census Block Groups, 2018")

p



# p <- ggplot(data = tomap_sf) +
#   theme_map() +
#   geom_sf(aes(fill = ea_idx)) +
#   scale_fill_viridis_c() +
#   ggtitle("Employment Access Index by Census Block Group", subtitle = "Marshalltown IA")
#
# p

#+
#geom_sf(data = mtown_stop_geo_tr, size = 0.5)
#+
#geom_text(data = tomap_coords, aes(X, Y, label = geoid), colour = "white")


# create map theme
# theme_map <- function(...) {
#   theme_minimal() +
#     theme(
#       text=element_text(family="mono", color="#22211d"),
#       axis.line=element_blank(),
#       axis.text.x=element_blank(),
#       axis.text.y=element_blank(),
#       axis.ticks=element_blank(),
#       axis.title.x=element_blank(),
#       axis.title.y=element_blank(),
#       # panel.grid.minor=element_line(color="#ebebe5", size=0.2),
#       panel.grid.major=element_line(color="#ebebe5", size=0.2),
#       panel.grid.minor=element_blank(),
#       plot.background=element_rect(fill="#f5f5f2", color = NA),
#       panel.background=element_rect(fill="#f5f5f2", color = NA),
#       legend.background=element_rect(fill="#f5f5f2", color = NA),
#       panel.border=element_blank(),
#       ...
#     )
# }




# # Get Blocks
# bg_blocks_ia <- get_blocks_within_distance_of_bg(bg = '191279507004', dist_mi = 60)
# # Get LODES
# lodes_ia_2015 <- data.table::setDT(read_lodes("ia", "od", "aux", "JT00", "2015", "data/sdad_data/original/CENSUS/LODES"))
# lodes_ia_2015[, w_geocode := as.character(w_geocode)]
# # Merge Blocks and LODES
# bg1_jobs <- merge(bg_blocks_ia, lodes_ia_2015, by.x = "geoid_block", by.y = "w_geocode")
# setDT(bg1_jobs)
#
# # Aggregate Jobs per Block
# bg1_jobs_2 <- bg1_jobs[,.(jobs_block=sum(as.numeric(S000))), .(geoid_bg, geoid_block, dist_mi)]
#
# # Calculate Index
# bg1_jobs_2[, .(jobs_block, d_sqr=dist_mi^2, e=jobs_block/(dist_mi^2))][, sum(e)]

#bg1_jobs_2[, dist_mi := (dist_m/1609.344)]
#bg1_jobs_2[, .(geoid_bg, geoid_block, jobs_block, dist_mi)]




# test1 <- get_blocks_within_distance_of_bg(bg = "510594809031", dist_mi = 100)
# test1[, .(jobs_block, d_sqr=dist_mi^2, e=jobs_block/(dist_mi^2))][, sum(e)]


# url_base <- "https://lehd.ces.census.gov/data/lodes/LODES7/va/od/"
# file_names <- webpage_link_urls(url_base)
# file_names_jt00 <- file_names[substr(file_names, 1, 14) == "va_od_aux_JT00"]
# file_urls_jt00 <- paste0(url_base, file_names_jt00)
#
# combined_jt00 <- fread_combine(file_urls_jt00)
# combined_jt00[, w_geocode_bg := substr(w_geocode, 1, 12)]
# combined_jt00[, h_geocode_bg := substr(h_geocode, 1, 12)]
#
# save(combined_jt00, file = "data/sdad_data/original/CENSUS/LODES/combined_va_od_jt00.RData")

#"191573704001005"


# get_bg_gravity <- function(bg_geoid_list, block_counts_df, block_geoid = "geoid", block_cnt = "tot_departs") {
#   #browser()
#   for (bgid in bg_geoid_list) {
#     # Get Blocks
#     bg_blocks <- get_blocks_within_distance_of_bg(bg = bgid, dist_mi = 60)
#
#     # Merge Blocks and LODES
#     bg1_count <- merge(bg_blocks, block_counts_df, by.x = "geoid_block", by.y = block_geoid)
#     setDT(bg1_count)
#
#     # Aggregate Jobs per Block
#     bg1_count_2 <- bg1_count[,.(block_cnt=sum(as.numeric(get(block_cnt)))), .(geoid_bg, geoid_block, dist_mi)]
#
#     # Calculate Index
#     idx <- bg1_count_2[, .(block_cnt, d_sqr=dist_mi^2, e=block_cnt/(dist_mi^2))][d_sqr==0, e := 0][, sum(e)]
#     idx_dt <- data.table(geoid = bgid, bgidx = idx)
#
#     # Combine
#     if (exists("idxes") == TRUE) idxes <- rbindlist(list(idxes, idx_dt))
#     else idxes <- idx_dt
#   }
#   idxes
# }


# con <- sdalr::con_db(dbname = "sdad", host = "127.0.0.1", port = 5433, user = "anonymous", pass = "anonymous")
# sql <- "SELECT distinct \"GEOID\" geoid, geometry FROM tl_2018_19_bg where left(\"GEOID\", 5) = '19127'"
# bg_geos <- sf::st_read(con, query = sql)
#
#
# transit_grav <- get_bg_gravity(bg_geos$geoid, stop_departures_block, block_geoid = "geoid")
# transit_grav$bgidx_lg <- log(transit_grav$bgidx)
#
# tomap <- merge(transit_grav, bg_geos, by = "geoid")
#
# excld <- c("191279501004","191279502002","191279502003","191279502001","191279503002","191279503003","191279503004","191279504004")
# tomap <- tomap[!tomap$geoid %in% excld,]
#
# tomap_sf <- sf::st_as_sf(tomap)
#
# ggplot(data = tomap_sf) +
#   geom_sf(aes(fill = bgidx_lg)) +
#   scale_fill_viridis_c() +
#   ggtitle("Transit Index by Census Block Group", subtitle = "Marshalltown IA")


# rm(idxes)
# myf <- function() {
# #browser()
# for (bgid in marshall_county_bgs$geoid) {
#   # Get Blocks
#   bg_blocks_ia <- get_blocks_within_distance_of_bg(bg = bgid, dist_mi = 60)
#
#   # Merge Blocks and LODES
#   bg1_jobs <- merge(bg_blocks_ia, lodes_ia_2015, by.x = "geoid_block", by.y = "w_geocode")
#   setDT(bg1_jobs)
#
#   # Aggregate Jobs per Block
#   bg1_jobs_2 <- bg1_jobs[,.(jobs_block=sum(as.numeric(S000))), .(geoid_bg, geoid_block, dist_mi)]
#
#   # Calculate Index
#   idx <- bg1_jobs_2[, .(jobs_block, d_sqr=dist_mi^2, e=jobs_block/(dist_mi^2))][d_sqr==0, e := 0][, sum(e)]
#   idx_dt <- data.table(geoid = bgid, bgidx = idx)
#
#   # Combine
#   if (exists("idxes") == TRUE) idxes <- rbindlist(list(idxes, idx_dt))
#   else idxes <- idx_dt
#
#
# }
#   idxes
# }
#
# m_bg_idxs <- setDF(myf())


# tomap_cp <- sf::st_centroid(tomap_sf)
# tomap_coords <- as.data.frame(sf::st_coordinates(tomap_cp))
# tomap_coords$geoid <- tomap_cp$geoid


# get_blocks_within_distance_of_bg <- function(bg = '510131016033', dist_mi = 2) {
#   st_code <- substr(bg, 1, 2)
#   sql <-
#     paste0(
#       "SELECT a.geoid geoid_bg, b.geoid geoid_block, ST_Distance(ST_Transform(a.geometry::geometry, 900913), ST_Transform(b.geometry::geometry, 900913))/1609.344 dist_mi
#      FROM geospatial$census_tl.tl_2018_", st_code, "_bg_centerpoints a
#      JOIN geospatial$census_tl.tl_2018_", st_code, "_block_centerpoints b
#      ON ST_Distance(ST_Transform(a.geometry::geometry, 900913), ST_Transform(b.geometry::geometry, 900913)) < (", dist_mi,"*1609.344)
#      WHERE a.geoid = '", bg, "'"
#     )
#   con <- sdalr::con_db(dbname = "sdad", host = "127.0.0.1", port = 5433, user = "anonymous", pass = "anonymous")
#   bg_blk_dists <- data.table::setDT(DBI::dbGetQuery(con, sql))
#   bg_blk_dists
# }
