library(plumber)
#* @apiTitle Simple API

#* Echo provided text
#* @param text The text to be echoed in the response
#* @get /echo
function(text = "") {
  list(
    message_echo = paste("The text is:", text)
  )
}

#* @apiTitle Block Group Proximity Blocks API

#* Get CENSUS blocks within x miles of a Block Group centerpoint
#* @param bg CENSUS block group
#* @param dist_mi distance in miles
#* @get /get_blocks_within_distance_of_bg
#* @post /get_blocks_within_distance_of_bg
get_blocks_within_distance_of_bg <- function(bg = '510131016033', dist_mi = 2) {
  st_code <- substr(bg, 1, 2)
  sql <-
    paste0(
      "SELECT a.geoid geoid_bg, b.geoid geoid_block, ST_Distance(ST_Transform(a.geometry::geometry, 900913), ST_Transform(b.geometry::geometry, 900913))/1609.344 dist_mi
     FROM geospatial$census_tl.tl_2018_", st_code, "_bg_centerpoints a
     JOIN geospatial$census_tl.tl_2018_", st_code, "_block_centerpoints b
     ON ST_Distance(ST_Transform(a.geometry::geometry, 900913), ST_Transform(b.geometry::geometry, 900913)) < (", dist_mi,"*1609.344)
     WHERE a.geoid = '", bg, "'"
    )
  #con <- sdalr::con_db(dbname = "sdad", host = "127.0.0.1", port = 5433, user = "anonymous", pass = "anonymous")
  con <- DBI::dbConnect(drv = RPostgreSQL::PostgreSQL(), dbname = "sdad", host = "127.0.0.1", port = 5433, user = "anonymous", pass = "anonymous")
  bg_blk_dists <- data.table::setDT(DBI::dbGetQuery(con, sql))
  DBI::dbDisconnect(con)
  bg_blk_dists
}

#* @apiTitle Block Group Gravity Index

#* Create a Gravity Model Index using a list of block group geoids (12 characters) and
#* a data.frame of block geoids and a count of something for each one
#* @param bg_geoid_list list of Census block group geoids (12 characters)
#* @param block_counts_df data.frame with a geoid column (15 characters) and a count of something per block column
#* @param block_cnt the name of the column holding the counts in block_counts_df
#* dist_mi the distance from each block group centerpoint from which block will be retrieved
#* @post /get_bg_gravity
get_bg_gravity <- function(bg_geoid_list, block_counts_df, block_geoid = "geoid", block_cnt = "tot_departs", dist_miles = 30) {
  library(data.table)
  for (bgid in bg_geoid_list) {
    # Get Blocks
    bg_blocks <- get_blocks_within_distance_of_bg(bg = bgid, dist_mi = dist_miles)

    # Merge Blocks and LODES
    bg1_count <- merge(bg_blocks, block_counts_df, by.x = "geoid_block", by.y = block_geoid)
    setDT(bg1_count)

    # Aggregate Jobs per Block
    bg1_count_2 <- bg1_count[,.(block_cnt=sum(as.numeric(get(block_cnt)))), .(geoid_bg, geoid_block, dist_mi)]

    # Calculate Index
    idx <- bg1_count_2[, .(block_cnt, d_sqr=dist_mi^2, e=block_cnt/(dist_mi^2))][d_sqr==0, e := 0][, sum(e)]
    idx_dt <- data.table(geoid = bgid, bgidx = idx)

    # Combine
    if (exists("idxes") == TRUE) idxes <- rbindlist(list(idxes, idx_dt))
    else idxes <- idx_dt
  }
  idxes
}










get_bg_gravity_js <- function(jsn) {
  o <- jsonlite::fromJSON(jsn)
  library(data.table)
  for (bgid in o$bg_geoid_list) {
    # Get Blocks
    bg_blocks <- get_blocks_within_distance_of_bg(bg = bgid, dist_mi = o$dist_miles)

    # Merge Blocks and LODES
    bg1_count <- merge(bg_blocks, o$block_counts_df, by.x = "geoid_block", by.y = o$block_geoid)
    setDT(bg1_count)

    # Aggregate Jobs per Block
    bg1_count_2 <- bg1_count[,.(block_cnt=sum(as.numeric(get(o$block_cnt)))), .(geoid_bg, geoid_block, dist_mi)]

    # Calculate Index
    idx <- bg1_count_2[, .(block_cnt, d_sqr=dist_mi^2, e=block_cnt/(dist_mi^2))][d_sqr==0, e := 0][, sum(e)]
    idx_dt <- data.table(geoid = bgid, bgidx = idx)

    # Combine
    if (exists("idxes") == TRUE) idxes <- rbindlist(list(idxes, idx_dt))
    else idxes <- idx_dt
  }
  idxes
}

#get_bg_gravity_js(jsn)
