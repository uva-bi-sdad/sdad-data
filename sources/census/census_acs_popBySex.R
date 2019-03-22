library(data.table)

# Get ACS Population by Sex
source(here::here('functions', 'get_acs.R'))
source(here::here('functions', 'metadata.R'))
source(here::here('functions', 'normalize_colname.R'))
source(here::here('functions', 'db_names.R'))

data_set_category <- "Demographics"
data_set_sub_category <- "Population"
data_set_name <- "Population by Sex"

# ds_id <- 5
ds_id <- data_set_metadata(data_set_source = "Census ACS",
                           data_set_name = data_set_name,
                           data_table_name = "va_bg_pop_by_sex_15",
                           data_set_url = "",
                           data_set_description = "American Community Survey 2015 Population by Sex",
                           data_set_notes = "",
                           data_set_last_update = "",
                           data_set_category = data_set_category,
                           data_set_sub_category = data_set_sub_category,
                           data_set_keywords = "census, acs, population, sex",
                           data_set_license = "public"
)

vars <- list(
  Female = list(variable = "B01001_026",
                description = "B01001. Sex by Age. All Female"
  ),
  Male = list(variable = "B01001_002",
              description = "B01001. Sex by Age. All Male"
  )
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
  ) %>%
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

# Write Data to Database
con <- sdalr::con_db("sdal")
DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", schema_name))
DBI::dbWriteTable(con, c(schema_name, table_name), data_table, row.names = F, overwrite = T)
