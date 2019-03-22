# query through every single mukeys in mukeys_bg_comb-------------------------------

#DO NOT RUN THIS, IT IS SAVED AS AN RDS*********************************************
mukeys_bg <- readRDS('./data/sdal_data/working/soil/mukey_per_latlong.RDS')

queries<- sprintf("SELECT
component.mukey, cokey, comppct_r, compname, taxclname,
taxorder, taxsuborder, taxgrtgroup, taxsubgrp
FROM legend
INNER JOIN mapunit ON mapunit.lkey = legend.lkey
INNER JOIN component ON component.mukey = mapunit.mukey
WHERE component.mukey = '%s'", unique(mukeys_bg$mukey))
soil_data <- purrr::map_df(queries, SDA_query)

saveRDS(soil_data, './data/sdal_data/working/soil/soil_data.RDS')
#***********************************************************************************



# mukeys_bg_joined <- mukeys_bg_comb %>% mutate(queries = sprintf("SELECT
# component.mukey, cokey, comppct_r, compname, taxclname,
# taxorder, taxsuborder, taxgrtgroup, taxsubgrp
# FROM legend
# INNER JOIN mapunit ON mapunit.lkey = legend.lkey
# INNER JOIN component ON component.mukey = mapunit.mukey
# WHERE component.mukey = '%s'", mukeys_bg_comb$mukey))
