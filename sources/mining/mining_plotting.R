
library(leaflet)
library(tibble)
library(sdalr)
library(dplyr)
library(readr)
library(sf)

source("R/sic_group.R")

clean_mines <- as.data.frame(read_csv("data/sdal_data/working/mining/clean_mines.csv"))

con <- con_db("sdal")
bg <- st_read(con, c("geospatial$census_cb", "cb_2016_51_bg_500k"))
state_bound <- st_read(con, c("geospatial$census_cb", "cb_2016_us_state_500k"))

bg <- bg %>% filter(COUNTYFP == "013"||COUNTYFP == "059")

bg$COUNTYFP <- as.factor(bg$COUNTYFP)
class(bg$COUNTYFP)

test <- split(bg, bg$COUNTYFP)

test[1]
test[2]

state_bound <- state_bound %>%
  filter(STUSPS == "VA")


clean_mines_va <- clean_mines %>%
  filter(!is.na(LONGITUDE|!is.na(LATITUDE))) %>%
  mutate(Mine_Status = ifelse(CURRENT_MINE_STATUS == "Active"|
                                CURRENT_MINE_STATUS == "Intermittent"|
                                CURRENT_MINE_STATUS == "New Mine",
                              "Active", "Inactive")) %>%
  mutate(icon = ifelse(Mine_Status == "Active", "circle", "square")) %>%
  mutate(material = lapply(PRIMARY_SIC, sic_group)) %>%
  mutate(LONGITUDE = LONGITUDE*-1) %>%
  filter(between(LONGITUDE, -83.689153, -76.199123) & between(LATITUDE, 36.598422, 39.465673))

clean_mines_va_sf <- clean_mines_va %>%
  st_as_sf(coords = c("LONGITUDE", "LATITUDE")) %>%
  st_set_crs(4269) %>%
  rownames_to_column()

clean_mines_va_sf$rowname <- as.integer(clean_mines_va_sf$rowname)
va_mines_yn <- st_within(clean_mines_va_sf, state_bound)
va_mine_rows <- as.data.frame(va_mines_yn)

clean_mines_va_sf <- clean_mines_va_sf %>%
  left_join(va_mine_rows, by = c("rowname" = "row.id")) %>%
  mutate(virginia = ifelse(is.na(col.id), "Other", "VA"))

clean_mines_va_sf <- clean_mines_va_sf %>%
  filter(virginia == "VA") %>%
  mutate(icon = ifelse(Mine_Status == "Active", "circle", "square"))

pal <- colorFactor(c("red", "black"), domain = c("Active", "Inactive"))

oceanIcons <- iconList(
  ship = makeIcon("ferry-18.png", "ferry-18@2x.png", 18, 18),
  pirate = makeIcon("danger-24.png", "danger-24@2x.png", 24, 24)
)

leaflet(clean_mines_va_sf) %>%
  addProviderTiles(providers$Stamen.TerrainBackground) %>%
  addCircles(color = ~pal(Mine_Status))



clean_mines_va_sf$material
