library(ggplot2)
library(maps)

air <- readr::read_csv('~/git/sdal_data/data/sdal_data/working/air_quality/combined_data.csv')
air <- air[!is.na(air$AQI),]

states <- map_data("state")
near_va <- subset(states, region %in% c("virginia", "maryland", "west virginia",
                                        "north carolina", "kentucky", "tennessee"))

ggplot(data = near_va) +
  geom_polygon(aes(x = long, y = lat, group = group), fill = "palegreen", color = "blue") +
  coord_fixed(1.3) +
  geom_point(data = air, aes(x = Longitude, y = Latitude))
