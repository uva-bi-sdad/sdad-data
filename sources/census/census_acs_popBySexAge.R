library(data.table)

# Get ACS Population by Sex
source(here::here('functions', 'get_acs.R'))
source(here::here('functions', 'metadata.R'))
source(here::here('functions', 'normalize_colname.R'))
source(here::here('functions', 'db_names.R'))

data_set_category <- "Demographics"
data_set_sub_category <- "Population"
data_set_name <- "Population by Sex and Age"
data_table_name <- "va_bg_pop_by_sex_and_age_15"

# ds_id <- 10
ds_id <- data_set_metadata(data_set_source = "Census ACS",
                           data_set_name = data_set_name,
                           data_table_name = data_table_name,
                           data_set_url = "",
                           data_set_description = "American Community Survey 2015 Population by Sex and Age",
                           data_set_notes = "",
                           data_set_last_update = "",
                           data_set_category = data_set_category,
                           data_set_sub_category = data_set_sub_category,
                           data_set_keywords = "census, acs, population, sex, age",
                           data_set_license = "public"
)

vars <- list(
  "Total" = list(variable = "B01001_001", description = "B01001_001 Population Total"),
  "Total Male" = list(variable = "B01001_002", description = "B01001_002 Population Total Male"),
  "Total Male Under 5 years" = list(variable = "B01001_003", description = "B01001_003 Population Total Male Under 5 years"),
  "Total Male 5 to 9 years" = list(variable = "B01001_004", description = "B01001_004 Population Total Male 5 to 9 years"),
  "Total Male 10 to 14 years" = list(variable = "B01001_005", description = "B01001_005 Population Total Male 10 to 14 years"),
  "Total Male 15 to 17 years" = list(variable = "B01001_006", description = "B01001_006 Population Total Male 15 to 17 years"),
  "Total Male 18 and 19 years" = list(variable = "B01001_007", description = "B01001_007 Population Total Male 18 and 19 years"),
  "Total Male 20 years" = list(variable = "B01001_008", description = "B01001_008 Population Total Male 20 years"),
  "Total Male 21 years" = list(variable = "B01001_009", description = "B01001_009 Population Total Male 21 years"),
  "Total Male 22 to 24 years" = list(variable = "B01001_010", description = "B01001_010 Population Total Male 22 to 24 years"),
  "Total Male 25 to 29 years" = list(variable = "B01001_011", description = "B01001_011 Population Total Male 25 to 29 years"),
  "Total Male 30 to 34 years" = list(variable = "B01001_012", description = "B01001_012 Population Total Male 30 to 34 years"),
  "Total Male 35 to 39 years" = list(variable = "B01001_013", description = "B01001_013 Population Total Male 35 to 39 years"),
  "Total Male 40 to 44 years" = list(variable = "B01001_014", description = "B01001_014 Population Total Male 40 to 44 years"),
  "Total Male 45 to 49 years" = list(variable = "B01001_015", description = "B01001_015 Population Total Male 45 to 49 years"),
  "Total Male 50 to 54 years" = list(variable = "B01001_016", description = "B01001_016 Population Total Male 50 to 54 years"),
  "Total Male 55 to 59 years" = list(variable = "B01001_017", description = "B01001_017 Population Total Male 55 to 59 years"),
  "Total Male 60 and 61 years" = list(variable = "B01001_018", description = "B01001_018 Population Total Male 60 and 61 years"),
  "Total Male 62 to 64 years" = list(variable = "B01001_019", description = "B01001_019 Population Total Male 62 to 64 years"),
  "Total Male 65 and 66 years" = list(variable = "B01001_020", description = "B01001_020 Population Total Male 65 and 66 years"),
  "Total Male 67 to 69 years" = list(variable = "B01001_021", description = "B01001_021 Population Total Male 67 to 69 years"),
  "Total Male 70 to 74 years" = list(variable = "B01001_022", description = "B01001_022 Population Total Male 70 to 74 years"),
  "Total Male 75 to 79 years" = list(variable = "B01001_023", description = "B01001_023 Population Total Male 75 to 79 years"),
  "Total Male 80 to 84 years" = list(variable = "B01001_024", description = "B01001_024 Population Total Male 80 to 84 years"),
  "Total Male 85 years and over" = list(variable = "B01001_025", description = "B01001_025 Population Total Male 85 years and over"),
  "Total Female" = list(variable = "B01001_026", description = "B01001_026 Population Total Female"),
  "Total Female Under 5 years" = list(variable = "B01001_027", description = "B01001_027 Population Total Female Under 5 years"),
  "Total Female 5 to 9 years" = list(variable = "B01001_028", description = "B01001_028 Population Total Female 5 to 9 years"),
  "Total Female 10 to 14 years" = list(variable = "B01001_029", description = "B01001_029 Population Total Female 10 to 14 years"),
  "Total Female 15 to 17 years" = list(variable = "B01001_030", description = "B01001_030 Population Total Female 15 to 17 years"),
  "Total Female 18 and 19 years" = list(variable = "B01001_031", description = "B01001_031 Population Total Female 18 and 19 years"),
  "Total Female 20 years" = list(variable = "B01001_032", description = "B01001_032 Population Total Female 20 years"),
  "Total Female 21 years" = list(variable = "B01001_033", description = "B01001_033 Population Total Female 21 years"),
  "Total Female 22 to 24 years" = list(variable = "B01001_034", description = "B01001_034 Population Total Female 22 to 24 years"),
  "Total Female 25 to 29 years" = list(variable = "B01001_035", description = "B01001_035 Population Total Female 25 to 29 years"),
  "Total Female 30 to 34 years" = list(variable = "B01001_036", description = "B01001_036 Population Total Female 30 to 34 years"),
  "Total Female 35 to 39 years" = list(variable = "B01001_037", description = "B01001_037 Population Total Female 35 to 39 years"),
  "Total Female 40 to 44 years" = list(variable = "B01001_038", description = "B01001_038 Population Total Female 40 to 44 years"),
  "Total Female 45 to 49 years" = list(variable = "B01001_039", description = "B01001_039 Population Total Female 45 to 49 years"),
  "Total Female 50 to 54 years" = list(variable = "B01001_040", description = "B01001_040 Population Total Female 50 to 54 years"),
  "Total Female 55 to 59 years" = list(variable = "B01001_041", description = "B01001_041 Population Total Female 55 to 59 years"),
  "Total Female 60 and 61 years" = list(variable = "B01001_042", description = "B01001_042 Population Total Female 60 and 61 years"),
  "Total Female 62 to 64 years" = list(variable = "B01001_043", description = "B01001_043 Population Total Female 62 to 64 years"),
  "Total Female 65 and 66 years" = list(variable = "B01001_044", description = "B01001_044 Population Total Female 65 and 66 years"),
  "Total Female 67 to 69 years" = list(variable = "B01001_045", description = "B01001_045 Population Total Female 67 to 69 years"),
  "Total Female 70 to 74 years" = list(variable = "B01001_046", description = "B01001_046 Population Total Female 70 to 74 years"),
  "Total Female 75 to 79 years" = list(variable = "B01001_047", description = "B01001_047 Population Total Female 75 to 79 years"),
  "Total Female 80 to 84 years" = list(variable = "B01001_048", description = "B01001_048 Population Total Female 80 to 84 years"),
  "Total Female 85 years and over" = list(variable = "B01001_049", description = "B01001_049 Population Total Female 85 years and over")
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
  by = "Sex and Age",
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
