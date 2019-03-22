library(readr)

clean_monitors <- monitors %>%
  filter(as.character.Date(`Last Sample Date`) >= "2004-01-01") %>%
  mutate('monitor_id' = paste(`State Code`,`County Code`,`Site Number`,`Parameter Code`,`POC`, sep = '-')) %>%
  select(`monitor_id`, `Latitude`,`Longitude`,`Last Sample Date`)
View(clean_monitors)


annual_AQI <- combined_data %>%
  mutate('monitor_id' = paste(`State Code`,`County Code`,`Site Num`,`Parameter Code`,`POC`, sep = '-')) %>%
  group_by(`monitor_id`,`Year`) %>%
  summarise(`annual_aqi` = mean(AQI))
View(annual_AQI)

test <- annual_AQI %>%
  dplyr::left_join(clean_monitors, by = 'monitor_id')
View(test)

write_csv(test, '~/git/sdal_data/data/sdal_data/final/annual_AQI.csv')
