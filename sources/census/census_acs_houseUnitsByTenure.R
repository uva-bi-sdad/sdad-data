library(data.table)

# Get ACS Population by Sex
source(here::here('functions', 'get_acs.R'))
source(here::here('functions', 'metadata.R'))
source(here::here('functions', 'normalize_colname.R'))
source(here::here('functions', 'db_names.R'))

data_set_category <- "Demographics"
data_set_sub_category <- "Housing"
data_set_name <- "Housing Units by Tenure"
data_table_name <- "va_bg_housing_units_by_tenure_15"

# ds_id <- 11
ds_id <- data_set_metadata(data_set_source = "Census ACS",
                           data_set_name = data_set_name,
                           data_table_name = data_table_name,
                           data_set_url = "",
                           data_set_description = "American Community Survey 2015 Housing Unit Counts",
                           data_set_notes = "Population in occupied housing units by tenure",
                           data_set_last_update = "",
                           data_set_category = data_set_category,
                           data_set_sub_category = data_set_sub_category,
                           data_set_keywords = "census, acs, household, units, tenure, own, rent",
                           data_set_license = "public"
)

vars <- list(
  "B25008_001" = list(variable = "B25008_001", description = "B25008_001 Housing Unit Counts Total"),
  "B25008_002" = list(variable = "B25008_002", description = "B25008_002 Housing Unit Counts Total Owner occupied"),
  "B25008_003" = list(variable = "B25008_003", description = "B25008_003 Housing Unit Counts Total Renter occupied")
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
  by = "Income",
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
      paste(data_set_name, 2015

      )
    )
  )
table_name

testthat::expect_equal(table_name, data_table_name)

# Write Data to Database
con <- sdalr::con_db("sdal")
DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", schema_name))
DBI::dbWriteTable(con, c(schema_name, table_name), data_table, row.names = F, overwrite = T)
