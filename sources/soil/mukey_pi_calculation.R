data = readRDS("./data/sdal_data/working/soil/PI_need_calc.RDS")

#check components
names(data)
unique(data$pi_value)
unique(data$mukey)
class(data$mukey)
#for each mukey, group by the mukeys
data$mukey = as.character(data$mukey)
compsum = data %>% group_by(mukey) %>% summarise(compsum = sum(comppct_r))
data = left_join(data, compsum, by = "mukey")

data$percent_comp = data$comppct_r/data$compsum
data$percent_spi = data$percent_comp * data$pi_value
x = data %>% group_by(mukey) %>% summarise(combined_spi = sum(percent_spi))
data = left_join(data, x, by = "mukey")

data = select(data, mukey, combined_spi)
data = unique(data)


mukey_per_latlong$mukey = as.character(mukey_per_latlong$mukey)
combined_data = left_join(mukey_per_latlong, data, by = "mukey")

#data should look like this (on test data)
saveRDS(combined_data, "./data/sdal_data/working/soil/final.RDS")
