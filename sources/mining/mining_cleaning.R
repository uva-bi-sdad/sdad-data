library(readr)
library(magrittr)
library(dplyr)
library(reshape)
# library(sf)

msha_Mines <- as.data.frame(read_csv("data/sdal_data/original/mining/msha_Mines.csv"))
msha_AddressofRecord <- as.data.frame(read_csv("data/sdal_data/original/mining/msha_AddressofRecord.csv"))

msha_Accidents <- as.data.frame(read_csv("data/sdal_data/original/mining/msha_Accidents.csv"))
msha_PersonalHealthSamples <- as.data.frame(read_csv("data/sdal_data/original/mining/msha_PersonalHealthSamples.csv"))

clean_mines <- msha_Mines %>%
  left_join(msha_AddressofRecord, by = c("MINE_ID", "STATE" = "STATE_ABBR",
                                         "PRIMARY_SIC" = "PRIMARY_SIC_CD",
                                         "NEAREST_TOWN", "COAL_METAL_IND",
                                         "CURRENT_MINE_TYPE" = "MINE_TYPE_CD",
                                         "CURRENT_MINE_STATUS" = "MINE_STATUS")) %>%
  select(MINE_ID, CURRENT_MINE_NAME, CURRENT_MINE_STATUS, CURRENT_MINE_TYPE, FIPS_CNTY_CD,
         FIPS_CNTY_NM, PRIMARY_SIC, SECONDARY_SIC, PRIMARY_CANVASS, SECONDARY_CANVASS,
         DAYS_PER_WEEK, HOURS_PER_SHIFT, PROD_SHIFTS_PER_DAY, NO_EMPLOYEES, NEAREST_TOWN,
         LONGITUDE, LATITUDE, METHANE_LIBERATION, STREET, CITY, STATE, STATE.y, ZIP_CD, COUNTRY)

head(clean_mines)

write.csv(clean_mines, "data/sdal_data/working/mining/clean_mines.csv")

# mine_injuries <- msha_Accidents %>%
#   select(MINE_ID, FIPS_STATE_CD, DEGREE_INJURY_CD, DEGREE_INJURY, CLASSIFICATION_CD,
#          CLASSIFICATION, ACCIDENT_TYPE_CD, ACCIDENT_TYPE, NO_INJURIES, NATURE_INJURY_CD,
#          NATURE_INJURY, DAYS_RESTRICT, DAYS_LOST, NARRATIVE) %>%
#   group_by(MINE_ID, CLASSIFICATION) %>%
#   summarise(total_accidents = sum(NO_INJURIES)) %>%
#   cast(MINE_ID~CLASSIFICATION, sum)







