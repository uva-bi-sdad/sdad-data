library(httr)
library(jsonlite)

bgids <-
  as.character(list(
    191279501001,
    191279501002,
    191279501003,
    191279503001,
    191279504001,
    191279504002,
    191279504003,
    191279505001,
    191279505002,
    191279505003,
    191279505004,
    191279506001,
    191279506002,
    191279506003,
    191279506004,
    191279506005,
    191279507001,
    191279507002,
    191279507003,
    191279507004,
    191279508001,
    191279508002,
    191279508003,
    191279508004,
    191279508005,
    191279508006,
    191279509001,
    191279509002,
    191279509003,
    191279509004,
    191279510001,
    191279510002,
    191279510003
  ))

block_list <- fread("test.csv", colClasses = c("character", "integer"))

l_json <- list(bg_geoid_list = bgids,
               block_counts_df = block_list,
               block_geoid = "geoid",
               block_cnt = "tot_departs",
               dist_miles = 2)

rm(resp)

# API Call
resp <-
  POST(
    url = "http://sdad.policy-analytics.net:8000/get_bg_gravity",
    body = l_json,
    encode = "json"
  )
content(resp)









# jsn <- jsonlite::toJSON(list(bg_geoid_list=bgids, block_counts_df=block_list, block_geoid="geoid", block_cnt="tot_departs", dist_miles=3))
# 
# get_bg_gravity <- function(bg_geoid_list, block_counts_df, block_geoid = "geoid", block_cnt = "tot_departs", dist_miles = 30) {
#   ls(environment())
# 
# }
# 
# get_bg_gravity(bg_geoid_list=bgids, block_counts_df=block_list_json, block_geoid="geoid", block_cnt="tot_departs", dist_miles=3)
# 
# 
# block_counts_df_json <- toJSON(block_list)
# 
# block_list_json <- jsonlite::toJSON(block_list)
# bg_geoid_list_json <- jsonlite::toJSON(bgids)
