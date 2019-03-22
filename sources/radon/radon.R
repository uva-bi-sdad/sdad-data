library(xlsx)
library(dplyr)
dat = read.xlsx("./luke_data/radonzones-table (1).xlsx", sheetIndex = 1)
View(dat)

dat = select(dat, County.Name, State, Radon.Zone)
View(dat)

dat = filter(dat, State == "VA")
View(dat)
dat = arrange(dat, dat$County.Name)
View(dat)

radon_zones_by_county_VA = dat
saveRDS(radon_zones_by_county_VA, "./luke_data/radon_zones_by_county_VA")

library(RPostgreSQL)
sdalr::con_db()
