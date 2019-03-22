#first, run the soil_indicator.R and then apply those functions on the data table queried by
#soil_db.R

#read rds------------------

binded_list = readRDS('./data/sdal_data/working/soil/soil_data.RDS')

#only keep the unique ones - duplicates can occur
#order------------------------- this works
order = binded_list$taxorder
binded_list$taxorder_recode <- pi_order(order)
binded_list$taxorder_recode <- stringr::str_replace(binded_list$taxorder_recode, "NULL", "0")
#check
table(binded_list$taxorder, binded_list$taxorder_recode, useNA = 'always')
binded_list$taxorder_recode <- as.numeric(binded_list$taxorder_recode)

#suborder-------------------------------
suborder = binded_list$taxsuborder

#this map2 is the one that is giving me trouble -
#it runs now but found no order and suborder match so everything returns 0
binded_list$taxsuborder_recode <- purrr::map2_chr(order, suborder, pi_suborder_mod)
#check
table(binded_list$taxsuborder, binded_list$taxsuborder_recode, useNA = 'always')
binded_list$taxsuborder_recode <- as.numeric(binded_list$taxsuborder_recode)

#grtgrp-------------------------
grtgrp = binded_list$taxgrtgroup
binded_list$grtgrp_recode <- purrr::map(grtgrp, pi_grtgrp_mod)
binded_list$grtgrp_recode <- unlist(binded_list$grtgrp_recode, recursive = TRUE, use.names = TRUE)
#check
table(binded_list$taxgrtgroup, binded_list$grtgrp_recode, useNA = 'always')
binded_list$grtgrp_recode <- as.numeric(binded_list$grtgrp_recode)

#subgrp----------------------
subgrp = binded_list$taxsubgrp
binded_list$subgrp_recode <- purrr::map(subgrp, pi_subgrp_mod)
binded_list$subgrp_recode <- unlist(binded_list$subgrp_recode, recursive = TRUE, use.names = TRUE)
#check
table(binded_list$taxsubgrp, binded_list$subgrp_recode, useNA = 'always')
binded_list$subgrp_recode <- as.numeric(binded_list$subgrp_recode)


#texture-------------------- this works!!
binded_list$taxclname_recode <- pi_taxclname(binded_list$taxclname)
table(binded_list$taxclname, binded_list$taxclname_recode, useNA = 'always')
binded_list$taxclname_recode <- as.numeric(binded_list$taxclname_recode)

#View(head(binded_list))
library(dplyr)
library(data.table)
library(dtplyr)
#adds all the components that makes up the soil PI
binded_list$pi_value <- binded_list$taxorder_recode +
  binded_list$taxsuborder_recode +
  binded_list$grtgrp_recode +
  binded_list$subgrp_recode +
  binded_list$taxclname_recode

saveRDS(binded_list, "./data/sdal_data/working/soil/PI_need_calc.RDS")



# chk = mukey_latlong %>%
#   data.table() %>%
#   select(mukey, Latitude, Longitude) %>%
#   mutate(mukey = as.character(x = mukey)) %>%
#   unique() %>%
#   data.table(key = 'mukey')
# str(mukey_latlong)
# output = merge(x = unique_binded_list %>%
#                  mutate(mukey = as.character(x = mukey)) %>%
#                  data.table(key = 'mukey'),
#                y = chk,
#                by = 'mukey')
# nrow(unique(binded_list))


#ignore ----------------------------------------------------------
mukey_with_latlong = merge(centroid, binded_list, key = "mukey")

table(str_detect(string = mukey_with_latlong$mukey,
                 pattern = '123059'))
# View(head(binded_list))

length(unique(mukey_latlong$mukey))
length(unique(binded_list$mukey))

count_mukey <- mukey_latlong %>%
  dplyr::group_by(mukey) %>%
  dplyr::summarise(n= n())

testthat::expect_true(all(count_mukey$n == 1))
