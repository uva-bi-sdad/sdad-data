library(data.table)

source(here::here('functions', 'get_acs.R'))
source(here::here('functions', 'normalize_colname.R'))
source(here::here('functions', 'db_names.R'))

# ACS 5 Education Attainment High school graduate - includes equivalency By Sex
by_1 <- get_acs_block_groups_multiple_counties (
  year = "2016",
  state = "VA",
  counties_fips = counties_fips(),
  variables = "B15002_028",
  output = "tidy",
  category = "Education",
  sub_category = "Achievement",
  display_name = "High school graduate - includes equivalency",
  by = "Sex",
  by_label = "Female",
  measure = "Number",
  data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
  data_source_abrev = "CENSUS:ACS5",
  description = "",
  definitions = ""
)

by_2 <- get_acs_block_groups_multiple_counties (
  year = "2016",
  state = "VA",
  counties_fips = counties_fips(),
  variables = "B15002_011",
  output = "tidy",
  category = "Education",
  sub_category = "Achievement",
  display_name = "High school graduate (includes equivalency)",
  by = "Sex",
  by_label = "Male",
  measure = "Number",
  data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
  data_source_abrev = "CENSUS:ACS5",
  description = "",
  definitions = ""
)

by_3 <- get_acs_block_groups_multiple_counties (
  year = "2015",
  state = "VA",
  counties_fips = counties_fips(),
  variables = "B15002_028",
  output = "tidy",
  category = "Education",
  sub_category = "Achievement",
  display_name = "High school graduate - includes equivalency",
  by = "Sex",
  by_label = "Female",
  measure = "Number",
  data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
  data_source_abrev = "CENSUS:ACS5",
  description = "",
  definitions = ""
)

by_4 <- get_acs_block_groups_multiple_counties (
  year = "2015",
  state = "VA",
  counties_fips = counties_fips(),
  variables = "B15002_011",
  output = "tidy",
  category = "Education",
  sub_category = "Achievement",
  display_name = "High school graduate (includes equivalency)",
  by = "Sex",
  by_label = "Male",
  measure = "Number",
  data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
  data_source_abrev = "CENSUS:ACS5",
  description = "",
  definitions = ""
)

by_5 <- get_acs_block_groups_multiple_counties (
  year = "2014",
  state = "VA",
  counties_fips = counties_fips(),
  variables = "B15002_028",
  output = "tidy",
  category = "Education",
  sub_category = "Achievement",
  display_name = "High school graduate (includes equivalency)",
  by = "Sex",
  by_label = "Female",
  measure = "Number",
  data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
  data_source_abrev = "CENSUS:ACS5",
  description = "",
  definitions = ""
)

by_6 <- get_acs_block_groups_multiple_counties (
  year = "2014",
  state = "VA",
  counties_fips = counties_fips(),
  variables = "B15002_011",
  output = "tidy",
  category = "Education",
  sub_category = "Achievement",
  display_name = "High school graduate (includes equivalency)",
  by = "Sex",
  by_label = "Male",
  measure = "Number",
  data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
  data_source_abrev = "CENSUS:ACS5",
  description = "",
  definitions = ""
)

by_7 <- get_acs_block_groups_multiple_counties (
  year = "2013",
  state = "VA",
  counties_fips = counties_fips(),
  variables = "B15002_028",
  output = "tidy",
  category = "Education",
  sub_category = "Achievement",
  display_name = "High school graduate (includes equivalency)",
  by = "Sex",
  by_label = "Female",
  measure = "Number",
  data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
  data_source_abrev = "CENSUS:ACS5",
  description = "",
  definitions = ""
)

by_8 <- get_acs_block_groups_multiple_counties (
  year = "2013",
  state = "VA",
  counties_fips = counties_fips(),
  variables = "B15002_011",
  output = "tidy",
  category = "Education",
  sub_category = "Achievement",
  display_name = "High school graduate (includes equivalency)",
  by = "Sex",
  by_label = "Male",
  measure = "Number",
  data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
  data_source_abrev = "CENSUS:ACS5",
  description = "",
  definitions = ""
)

data_table <- data.table::rbindlist(list(by_1, by_2, by_3, by_4, by_5, by_6, by_7, by_8))

# Create Schema and Table Names
schema_name <-
  gsub("-", "", gsub(" +", "_", gsub("&", "", tolower(paste0(
    data_table[1, CATEGORY], "$", data_table[1, SUB_CATEGORY]
  )))))
table_name <-
  make_db_table_name(
    paste(
      "VA",
      "",
      "Block Group",
      paste(data_table[1, DISPLAY_NAME], min(data_table$YEAR), if(max(data_table$YEAR) != min(data_table$YEAR)) max(data_table$YEAR))
    )
  )

# Write Data to Database
con <- sdalr::con_db("sdal")
DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", schema_name))
DBI::dbWriteTable(con, c(schema_name, table_name), data_table, row.names = F, overwrite = T)
