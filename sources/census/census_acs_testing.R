less_than_9th_male <- c("B15002_003", "B15002_004", "B15002_005", "B15002_006")
ninth_12_no_dp_male <- c("B15002_007", "B15002_008", "B15002_009", "B15002_010")
hs_grad_male <- c("B15002_011")
some_college_no_degree_male <- c("B15002_012", "B15002_013")
assoc_male <- c("B15002_014")
bach_male <- c("B15002_015")
grad_prof_male <- c("B15002_016", "B15002_017", "B15002_018")

less_than_9th_female <- c("B15002_020", "B15002_021", "B15002_022", "B15002_023")
ninth_12_no_dp_female <- c("B15002_024", "B15002_025", "B15002_026", "B15002_027")
hs_grad_female <- c("B15002_028")
some_college_no_degree_female <- c("B15002_029", "B15002_030")
assoc_female <- c("B15002_031")
bach_female <- c("B15002_032")
grad_prof_female <- c("B15002_033", "B15002_034", "B15002_035")


if (exists("data_table") == T) rm("data_table")
for (id in less_than_9th_male) {
  by_i <- get_acs_block_groups_multiple_counties (
    year = "2013",
    state = "VA",
    counties_fips = counties_fips(),
    variables = id,
    output = "tidy",
    category = "Education",
    sub_category = "Achievement",
    display_name = "Less than 9th Grade Male",
    by = "Sex & Achievement",
    by_label = "Less than 9th Grade Male",
    measure = "Number",
    data_source = "U.S. Census Bureau, American Community Survey (ACS) 5 year estimates",
    data_source_abrev = "CENSUS:ACS5",
    description = "",
    definitions = ""
  )
  
  if (exists("data_table") == F) {
    data_table <- by_i
  } else {
    data_table <- data.table::rbindlist(list(data_table, by_i))
  }
}

dtg <-
  data_table[, 
             .(VALUE = sum(VALUE), MOE = mean(MOE)) ,
             c("NAMELSAD",
               "YEAR",
               "CATEGORY",
               "SUB_CATEGORY",
               "DISPLAY_NAME",
               "BY",
               "BY_LABEL",
               "MEASURE",
               "DESCRIPTION",
               "DEFINITIONS",
               "DATA_SOURCE",
               "DATA_SOURCE_ABREV",
               "ST_SUBST_FIPS",
               "CONTAINING_GEOID")
             ]




