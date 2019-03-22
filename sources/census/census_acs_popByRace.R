library(data.table)

# Get ACS Population by Sex
source(here::here('functions', 'get_acs.R'))
source(here::here('functions', 'metadata.R'))
source(here::here('functions', 'normalize_colname.R'))
source(here::here('functions', 'db_names.R'))

data_set_category <- "Demographics"
data_set_sub_category <- "Population"
data_set_name <- "Population by Race"
data_table_name <- "va_bg_pop_by_race_15"

# ds_id <- 8
ds_id <- data_set_metadata(data_set_source = "Census ACS",
                           data_set_name = data_set_name,
                           data_table_name = data_table_name,
                           data_set_url = "",
                           data_set_description = "American Community Survey 2015 Population by Race",
                           data_set_notes = "",
                           data_set_last_update = "",
                           data_set_category = data_set_category,
                           data_set_sub_category = data_set_sub_category,
                           data_set_keywords = "census, acs, population, race",
                           data_set_license = "public"
)

vars <- list(
  White = list(variable = "B02001_002",
               description = "B02001_002 Population by Race (White)"
  ),
  Black = list(variable = "B02001_003",
               description = "B02001_003 Population by Race (Black)"
  ),
  "American Indian" = list(variable = "B02001_004",
                           description = "B02001_004 Population by Race (American Indian)"
  ),
  Asian = list(variable = "B02001_005",
               description = "B02001_005 Population by Race (Asian)"
  ),
  "Pacific Islander" = list(variable = "B02001_006",
                            description = "B02001_006 Population by Race (Pacific Islander)"
  ),
  "Some Other Race" = list(variable = "B02001_007",
                           description = "B02001_007 Population by Race (Some Other Race)"
  ),
  "Two or More Races" = list(variable = "B02001_008",
                             description = "B02001_008 Population by Race (Two or More Races)"
  )
  # could not find a table that does not return NULL values for the estimate
  # "Hispanic or Latino" = list(variable = "B01001I_001",
  #                             description = "B01001I_001 Population by Race (Hispanic or Latino)"
  # )
)

args <- list(
  variables = sapply(vars, FUN = '[[', 'variable'),
  by_label = names(vars),
  description = sapply(vars, FUN = '[[', 'description'),

  ds_id = ds_id,
  year = "2015",
  state = "VA",
  geo_level = "bg",
  output = "tidy",
  by = "Sex",
  measure = "Number",
  notes = ""
)

data_table <- args %>%
  purrr::pmap(.GlobalEnv$get_acs_block_groups_multiple_counties,
    counties_fips = .GlobalEnv$counties_fips()
  )

data_table <- data_table %>%
  data.table::rbindlist(l = .)

# Create Schema and Table Names
schema_name <- .GlobalEnv$create_schema_name(data_set_category, data_set_sub_category)
schema_name

table_name <-
  make_db_table_name(
    paste(
      "VA",
      "",
      "Block Group",
      paste(data_set_name,
            min(data_table$item_year),
            if (max(data_table$item_year) != min(data_table$item_year)) max(data_table$item_year)
      )
    )
  )
table_name

testthat::expect_equal(table_name, data_table_name)

# Write Data to Database
con <- sdalr::con_db("sdal")
DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", schema_name))
DBI::dbWriteTable(con, c(schema_name, table_name), data_table, row.names = F, overwrite = T)
