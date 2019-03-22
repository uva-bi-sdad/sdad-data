# Get ACS Population by Sex
source("functions/get_acs.R")
by_1 <-
  get_acs_block_groups_multiple_counties(
    category = "Demographics",
    sub_category = "Population",
    display_name = "Population by Sex",
    year = "2015",
    state = "VA",
    counties_fips = counties_fips(),
    variables = "B01001_026",
    by = "Sex",
    by_label = "Female",
    measure = "Number",
    data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
    data_source_abrev = "CENSUS:ACS5",
    description = "B01001. Sex by Age. All Female",
    definitions = ""
  )
by_2 <-
  get_acs_block_groups_multiple_counties(
    category = "Demographics",
    sub_category = "Population",
    display_name = "Population by Sex",
    year = "2015",
    state = "VA",
    counties_fips = counties_fips(),
    variables = "B01001_002",
    by = "Sex",
    by_label = "Male",
    measure = "Number",
    data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
    data_source_abrev = "CENSUS:ACS5",
    description = "B01001. Sex by Age. All Male",
    definitions = ""
  )
data_table <- data.table::rbindlist(list(by_1, by_2))

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

# Get ACS Population by Race
source("functions/get_acs.R")
by_1 <-
  get_acs_block_groups_multiple_counties(
    category = "Demographics",
    sub_category = "Population",
    display_name = "Population by Race",
    year = "2015",
    state = "VA",
    counties_fips = counties_fips(),
    variables = "B01001A_001",
    by = "Race",
    by_label = "White",
    measure = "Number",
    data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
    data_source_abrev = "CENSUS:ACS5",
    description = "Population by Race",
    definitions = ""
  )
by_2 <-
  get_acs_block_groups_multiple_counties(
    category = "Demographics",
    sub_category = "Population",
    display_name = "Population by Race",
    year = "2015",
    state = "VA",
    counties_fips = counties_fips(),
    variables = "B01001B_001",
    by = "Race",
    by_label = "Black or African American",
    measure = "Number",
    data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
    data_source_abrev = "CENSUS:ACS5",
    description = "Population by Race",
    definitions = ""
  )
by_3 <-
  get_acs_block_groups_multiple_counties(
    category = "Demographics",
    sub_category = "Population",
    display_name = "Population by Race",
    year = "2015",
    state = "VA",
    counties_fips = counties_fips(),
    variables = "B01001C_001",
    by = "Race",
    by_label = "American Indian",
    measure = "Number",
    data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
    data_source_abrev = "CENSUS:ACS5",
    description = "Population by Race",
    definitions = ""
  )
by_4 <-
  get_acs_block_groups_multiple_counties(
    category = "Demographics",
    sub_category = "Population",
    display_name = "Population by Race",
    year = "2015",
    state = "VA",
    counties_fips = counties_fips(),
    variables = "B01001D_001",
    by = "Race",
    by_label = "Asian",
    measure = "Number",
    data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
    data_source_abrev = "CENSUS:ACS5",
    description = "Population by Race",
    definitions = ""
  )
by_5 <-
  get_acs_block_groups_multiple_counties(
    category = "Demographics",
    sub_category = "Population",
    display_name = "Population by Race",
    year = "2015",
    state = "VA",
    counties_fips = counties_fips(),
    variables = "B01001E_001",
    by = "Race",
    by_label = "Pacific Islander",
    measure = "Number",
    data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
    data_source_abrev = "CENSUS:ACS5",
    description = "Population by Race",
    definitions = ""
  )
by_6 <-
  get_acs_block_groups_multiple_counties(
    category = "Demographics",
    sub_category = "Population",
    display_name = "Population by Race",
    year = "2015",
    state = "VA",
    counties_fips = counties_fips(),
    variables = "B01001F_001",
    by = "Race",
    by_label = "Some Other Race",
    measure = "Number",
    data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
    data_source_abrev = "CENSUS:ACS5",
    description = "Population by Race",
    definitions = ""
  )
by_7 <-
  get_acs_block_groups_multiple_counties(
    category = "Demographics",
    sub_category = "Population",
    display_name = "Population by Race",
    year = "2015",
    state = "VA",
    counties_fips = counties_fips(),
    variables = "B01001G_001",
    by = "Race",
    by_label = "Two or More Races",
    measure = "Number",
    data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
    data_source_abrev = "CENSUS:ACS5",
    description = "Population by Race",
    definitions = ""
  )
by_8 <-
  get_acs_block_groups_multiple_counties(
    category = "Demographics",
    sub_category = "Population",
    display_name = "Population by Race",
    year = "2015",
    state = "VA",
    counties_fips = counties_fips(),
    variables = "B01001I_001",
    by = "Race",
    by_label = "Hispanic or Latino",
    measure = "Number",
    data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
    data_source_abrev = "CENSUS:ACS5",
    description = "Population by Race",
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



# Get ACS Population by Age Group
source("functions/get_acs.R")
under5_2015 <- get_acs_block_groups(variables = c("B01001_003E", "B01001_027E"))


# Get ACS Population Female < 45
# fu45 <- get_acs_block_groups(variables = c("B01001_027", "B01001_028", "B01001_029", "B01001_030", "B01001_031", "B01001_032", "B01001_033", "B01001_034", "B01001_035", "B01001_036", "B01001_037", "B01001_038"))
source("functions/get_acs.R")
va_co_ext <- data.table::setDT(read.csv("data/va_county_fips_extension_districts.csv", stringsAsFactors = FALSE, colClasses = "character"))
co_fips <- va_co_ext[DISTRICT=="Central", .(COUNTYFP)][[1]]
vars <- c(
  "B01001_027",
  "B01001_028",
  "B01001_029",
  "B01001_030",
  "B01001_031",
  "B01001_032",
  "B01001_033",
  "B01001_034",
  "B01001_035",
  "B01001_036",
  "B01001_037",
  "B01001_038"
)
fu45_2015 <-
  get_acs_block_groups_multiple_counties(year = "2015",
                                         counties_fips = co_fips,
                                         variables = vars)
fu45_2014 <-
  get_acs_block_groups_multiple_counties(year = "2014",
                                         counties_fips = co_fips,
                                         variables = vars)
fu45_2013 <-
  get_acs_block_groups_multiple_counties(year = "2013",
                                         counties_fips = co_fips,
                                         variables = vars)
fu45_2012 <-
  get_acs_block_groups_multiple_counties(year = "2012",
                                         counties_fips = co_fips,
                                         variables = vars)
fu45_2011 <-
  get_acs_block_groups_multiple_counties(year = "2011",
                                         counties_fips = co_fips,
                                         variables = vars)

fu45 <-
  data.table::rbindlist(list(fu45_2011, fu45_2012, fu45_2013, fu45_2014, fu45_2015))
fu45 <-
  fu45[, .(VALUE = sum(VALUE), MOE = round(base::mean(MOE))), .(
    YEAR,
    NAMELSAD,
    CATEGORY,
    SUB_CATEGORY,
    DISPLAY_NAME,
    BY,
    BY_LABEL,
    MEASURE,
    DESCRIPTION,
    DEFINITIONS,
    DATA_SOURCE,
    DATA_SOURCE_ABREV,
    ST_SUBST_FIPS,
    CONTAINING_GEOID
  )]

saveRDS(fu45, "data/CENSUS/fu45.RDS")

# grp <- fu45[YEAR == "2011", .(f_under_45 = sum(VALUE)), NAMELSAD]
# grp

# Get ACS Households with Own Children < 12
source("functions/get_acs.R")
va_co_ext <- data.table::setDT(read.csv("data/va_county_fips_extension_districts.csv", stringsAsFactors = FALSE, colClasses = "character"))
co_fips <- va_co_ext[DISTRICT=="Central", .(COUNTYFP)][[1]]
vars <- c(
  "B09002_003",
  "B09002_004",
  "B09002_005",
  "B09002_006",
  "B09002_010",
  "B09002_011",
  "B09002_012",
  "B09002_013",
  "B09002_016",
  "B09002_017",
  "B09002_018",
  "B09002_019"
)
cu12_2015 <-
  get_acs_block_groups_multiple_counties(year = "2015",
                                         counties_fips = co_fips,
                                         variables = vars)
cu12_2014 <-
  get_acs_block_groups_multiple_counties(year = "2014",
                                         counties_fips = co_fips,
                                         variables = vars)
cu12_2013 <-
  get_acs_block_groups_multiple_counties(year = "2013",
                                         counties_fips = co_fips,
                                         variables = vars)
cu12_2012 <-
  get_acs_block_groups_multiple_counties(year = "2012",
                                         counties_fips = co_fips,
                                         variables = vars)
cu12_2011 <-
  get_acs_block_groups_multiple_counties(year = "2011",
                                         counties_fips = co_fips,
                                         variables = vars)

cu12 <-
  data.table::rbindlist(list(cu12_2011, cu12_2012, cu12_2013, cu12_2014, cu12_2015))
cu12 <-
  cu12[, .(VALUE = sum(VALUE), MOE = round(base::mean(MOE))), .(
    YEAR,
    NAMELSAD,
    CATEGORY,
    SUB_CATEGORY,
    DISPLAY_NAME,
    BY,
    BY_LABEL,
    MEASURE,
    DESCRIPTION,
    DEFINITIONS,
    DATA_SOURCE,
    DATA_SOURCE_ABREV,
    ST_SUBST_FIPS,
    CONTAINING_GEOID
  )]

saveRDS(cu12, "data/CENSUS/cu12.RDS")


# Combine Family & Community Tables
family <- data.table::rbindlist(list(family_1))
write.csv(family, "data/dash_tables/family_community_indicators.csv", row.names = FALSE)
