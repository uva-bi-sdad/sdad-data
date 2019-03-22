library(tidyverse)
library(tidycensus)
library(data.table)

census_api_key("636a0df8dabd6c37220aeca7f1da41bbe1c5b30e")

#' Converts the tidycencus::get_acs result into a data.table where `geography` is `'block group'`
#'
#' @param year Number or string for the year or end year of the ACS sample
#' @param state Number or string that represents the FIPS code or 2-letter abbreviation for a state
#' @param county Number or string that represents the county FIPS code
#' @param variables Character string or vector of character strings of variable IDs
#' @param output "tidy" or "wide" output, defaults to "tidy"
#' @param silent TRUE or FALSE, whether to `supressMessages` from the `get_acs` call
#' @param ... Additional parameters passed into tidycensus::get_acs
#' @return data.table result from tidycensus::get_acs
#' @examples
#' get_acs_block_groups(year = 2015, state = "VA", county = "001", variables = "B01001_026", output = "tidy")
get_acs_block_groups <- function(year, state, county, variables, output = "tidy", silent = TRUE, ...) {
  if (silent) {
    dt <- suppressMessages(
      data.table::setDT(
        get_acs(
          geography = "block group",
          year = year,
          state = state,
          county = county,
          variables = variables,
          output = output,
          ... = ...
        )
      )
    )
  } else {
    dt <- data.table::setDT(
      get_acs(
        geography = "block group",
        year = year,
        state = state,
        county = county,
        variables = variables,
        output = output,
        ... = ...
      )
    )
  }
  return(dt)
}

#' Get block group data from multiple counties.
#' Calls `get_acs_block_groups` to get the individual block group data.`
#'
#' @param year Number or string
#' @param silent TRUE or FALSE, whether to `supressMessages` from the `get_acs` call
#'
get_acs_block_groups_multiple_counties <- function(
  ds_id,
  year, state, counties_fips, variables, output,
  by,
  by_label,
  notes,
  measure,
  description,
  geo_level = "bg",
  silent = TRUE) {

  acs_bg <- lapply(X = counties_fips, FUN = function(x){
    get_acs_block_groups(
      year = year,
      state = state,
      county = x,
      variables = variables,
      output = output,
      silent = silent)})
  acs_bg <- data.table::rbindlist(acs_bg)

  # "cbinding" metadata
  cdata <- list(
    "data_set_id" = ds_id,
    "item_geolevel" = geo_level,
    "item_year" = year,
    "item_description" = description,
    "item_by" = by,
    "item_by_value" = by_label,
    "item_notes" = notes,
    "item_measure" = measure
  )
  acs_bg[, names(cdata) := cdata]

  # rename columns
  renames <- c("estimate" = "item_value",
               "NAME" = "item_name",
               "GEOID" = 'item_geoid',
               "moe" = 'item_moe'
  )
  setnames(acs_bg, names(renames), renames)

  print(head(acs_bg))
  return(acs_bg)
}

#' Converts the tidycencus::get_acs result into a data.table where `geography` is `'county'`
#'
#' @param silent TRUE or FALSE, whether to `supressMessages` from the `get_acs` call
#'
get_acs_counties <- function(year = "2015", state = "VA", variables = "B01001_026", silent = TRUE, ...) {
  if (silent) {
    suppressMessages(
      data.table::setDT(get_acs(
        geography = "county",
        year = year,
        state = state,
        variables = variables,
        ... = ...
      ))
    )
  } else {
    data.table::setDT(get_acs(
      geography = "county",
      year = year,
      state = state,
      variables = variables,
      ... = ...
    ))
  }

}

counties_fips <- function() {
  c(
    "001",
    "003",
    "005",
    "007",
    "009",
    "011",
    "013",
    "015",
    "017",
    "019",
    "021",
    "023",
    "025",
    "027",
    "029",
    "031",
    "033",
    "035",
    "036",
    "037",
    "041",
    "043",
    "045",
    "047",
    "049",
    "051",
    "053",
    "057",
    "059",
    "061",
    "063",
    "065",
    "067",
    "069",
    "071",
    "073",
    "075",
    "077",
    "079",
    "081",
    "083",
    "085",
    "087",
    "089",
    "091",
    "093",
    "095",
    "097",
    "099",
    "101",
    "103",
    "105",
    "107",
    "109",
    "111",
    "113",
    "115",
    "117",
    "119",
    "121",
    "125",
    "127",
    "131",
    "133",
    "135",
    "137",
    "139",
    "141",
    "143",
    "145",
    "147",
    "149",
    "153",
    "155",
    "157",
    "159",
    "161",
    "163",
    "165",
    "167",
    "169",
    "171",
    "173",
    "175",
    "177",
    "179",
    "181",
    "183",
    "185",
    "187",
    "191",
    "193",
    "195",
    "197",
    "199",
    "510",
    "520",
    "530",
    "540",
    "550",
    "570",
    "580",
    "590",
    "595",
    "600",
    "610",
    "620",
    "630",
    "640",
    "650",
    "660",
    "670",
    "678",
    "680",
    "683",
    "685",
    "690",
    "700",
    "710",
    "720",
    "730",
    "735",
    "740",
    "750",
    "760",
    "770",
    "775",
    "790",
    "800",
    "810",
    "820",
    "830",
    "840"
  )
}
