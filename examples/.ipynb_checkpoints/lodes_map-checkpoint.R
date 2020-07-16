library(data.table)
library(sf)
library(sdalr)
load("data/sdad_data/original/CENSUS/LODES/combined_va_od_jt00.RData")
#arl_bg_pop <- tidycensus::get_acs(geography = "block group", variables = "B00001_001", state = "VA", county = "Arlington", geometry = TRUE)

con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
census_tl_va_bg_2016 <- sf::st_read(con, c("geospatial$census_tl", "tl_2018_51_bg"))

lodes_od_jt00_va_bg_2014 <- combined_jt00[file_name %like% "2014", .(job_cnt = sum(as.numeric(S000))), w_geocode_bg]
names(lodes_od_jt00_va_bg_2014)[names(lodes_od_jt00_va_bg_2014) == 'w_geocode_bg'] <- 'GEOID'

jobs_va_bg_2014 <- merge(census_tl_va_bg_2016, lodes_od_jt00_va_bg_2014, by = "GEOID", all.x = T)
plot(jobs_va_bg_2014[,c("job_cnt")])

