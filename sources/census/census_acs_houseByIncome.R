library(data.table)

# Get ACS Population by Sex
source(here::here('functions', 'get_acs.R'))
source(here::here('functions', 'metadata.R'))
source(here::here('functions', 'normalize_colname.R'))
source(here::here('functions', 'db_names.R'))

data_set_category <- "Demographics"
data_set_sub_category <- "Housing"
data_set_name <- "Households by Income"
data_table_name <- "va_bg_hshlds_by_inc_15"

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


# ds_id <- 11
ds_id <- data_set_metadata(data_set_source = "Census ACS",
                           data_set_name = data_set_name,
                           data_table_name = data_table_name,
                           data_set_url = "",
                           data_set_description = "American Community Survey 2015 Household income",
                           data_set_notes = "Household income in the past 12 months (in 2015 inflation-adjusted dollars)",
                           data_set_last_update = "",
                           data_set_category = data_set_category,
                           data_set_sub_category = data_set_sub_category,
                           data_set_keywords = "census, acs, household, income, demographics",
                           data_set_license = "public"
)

vars <- list(
  "Total" = list(variable = "B19001_001", description = "B19001_001 Household Income Total"),
  "Total Less than $10,000" = list(variable = "B19001_002", description = "B19001_002 Household Income Total Less than $10,000"),
  "Total $10,000 to $14,999" = list(variable = "B19001_003", description = "B19001_003 Household Income Total $10,000 to $14,999"),
  "Total $15,000 to $19,999" = list(variable = "B19001_004", description = "B19001_004 Household Income Total $15,000 to $19,999"),
  "Total $20,000 to $24,999" = list(variable = "B19001_005", description = "B19001_005 Household Income Total $20,000 to $24,999"),
  "Total $25,000 to $29,999" = list(variable = "B19001_006", description = "B19001_006 Household Income Total $25,000 to $29,999"),
  "Total $30,000 to $34,999" = list(variable = "B19001_007", description = "B19001_007 Household Income Total $30,000 to $34,999"),
  "Total $35,000 to $39,999" = list(variable = "B19001_008", description = "B19001_008 Household Income Total $35,000 to $39,999"),
  "Total $40,000 to $44,999" = list(variable = "B19001_009", description = "B19001_009 Household Income Total $40,000 to $44,999"),
  "Total $45,000 to $49,999" = list(variable = "B19001_010", description = "B19001_010 Household Income Total $45,000 to $49,999"),
  "Total $50,000 to $59,999" = list(variable = "B19001_011", description = "B19001_011 Household Income Total $50,000 to $59,999"),
  "Total $60,000 to $74,999" = list(variable = "B19001_012", description = "B19001_012 Household Income Total $60,000 to $74,999"),
  "Total $75,000 to $99,999" = list(variable = "B19001_013", description = "B19001_013 Household Income Total $75,000 to $99,999"),
  "Total $100,000 to $124,999" = list(variable = "B19001_014", description = "B19001_014 Household Income Total $100,000 to $124,999"),
  "Total $125,000 to $149,999" = list(variable = "B19001_015", description = "B19001_015 Household Income Total $125,000 to $149,999"),
  "Total $150,000 to $199,999" = list(variable = "B19001_016", description = "B19001_016 Household Income Total $150,000 to $199,999"),
  "Total $200,000 or more" = list(variable = "B19001_017", description = "B19001_017 Household Income Total $200,000 or more")
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


# Write Data to Database
con <- sdalr::con_db("sdal")
DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", schema_name))
DBI::dbWriteTable(con, c(schema_name, table_name), data_table, row.names = F, overwrite = T)
