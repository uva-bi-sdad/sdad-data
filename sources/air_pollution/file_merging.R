setwd('~/git/sdal_data/data/sdal_data/original/air_quality/')
library(dplyr)
library(readr)

df <- list.files(full.names = TRUE) %>%
  lapply(read_csv) %>%
  bind_rows
df <- df[!is.na(df$AQI),]

df <- df %>%
  mutate(Year = substr(`Date Local`,1,4))

write_csv(df, '~/git/sdal_data/data/sdal_data/working/air_quality/combined_data.csv')

