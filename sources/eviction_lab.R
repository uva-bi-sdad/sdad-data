library(data.table)

# Create Data Set Metadata Entry and get Id ----------------------------------------------

ds_id <- data_set_metadata(data_set_source = "Eviction Lab",
                           data_set_name = "U.S. Evictions 2000 - 2016",
                           data_table_name = "us_evictions_00_16",
                           data_set_url = "https://data-downloads.evictionlab.org/",
                           data_set_description = "The data the Eviction Lab collected is comprised of formal eviction records from 48 states and the District of Columbia. Eviction records include information related to an eviction court case, such as defendant and plaintiff names, the defendant’s address, monetary judgment information, and an outcome for the case. We combined these records with demographic information from the Census to paint a better picture of the areas in which these evictions are happening.

The Eviction Lab has also collected state reported, county-level statistics on landlord-tenant cases filed from 27 states, New York City, and the District of Columbia. This includes two of the states where we are missing individual-level eviction records – North and South Dakota. Together, these statistics represent all the known information on the number of evictions filed in counties and made publically-available by municipalities.",
                           data_set_notes = "A “filing rate” is the ratio of the number of evictions filed in an area over the number of renter-occupied homes in that area. An “eviction rate” is the subset of those homes that received an eviction judgement in which renters were ordered to leave. The filing rate also counts all eviction cases filed in an area, including multiple cases filed against the same address in the same year. But an eviction rate only counts a single address who received an eviction judgement.",
                           data_set_last_update = "",
                           data_set_category = "Economic Well-Being",
                           data_set_sub_category = "Housing",
                           data_set_keywords = "Eviction, Housing, Economics"
                           )



# get data all states
. <- data.table()
for (s in c(state.abb, "DC")) {
  .. <- fread(sprintf("https://eviction-lab-data-downloads.s3.amazonaws.com/%s/all.csv", s), colClasses = "character")
  . <- rbindlist(list(., ..), fill = T)
}
dt <- .

# transform eviction data columns to long
. <- melt(
  dt,
  id.vars = c("GEOID", "year"),
  measure.vars = c(
    "eviction-filings",
    "evictions",
    "eviction-rate",
    "eviction-filing-rate"
  )
)

# change column names
colnames(.) <- c("item_geoid", "item_year", "item_name", "item_value")

# add additional columns and values
.[, data_set_id := ds_id]
.[, item_description := ""]
.[, item_notes := ""]
.[, item_by := ""]
.[, item_by_value := ""]
.[, item_last_update := ""]
.[item_name %like% "rate$", item_measure := "rate"]
.[!item_name %like% "rate$", item_measure := "count"]
.[nchar(trimws(item_geoid)) == 12, item_geolevel := "bg"]
.[nchar(trimws(item_geoid)) == 11, item_geolevel := "tr"]
.[nchar(trimws(item_geoid)) == 5, item_geolevel := "ct"]
.[nchar(trimws(item_geoid)) == 2, item_geolevel := "st"]

# re-order columns
setcolorder(., c("data_set_id", "item_geoid", "item_geolevel", "item_year",
                 "item_name", "item_description", "item_by", "item_by_value", "item_notes", "item_measure",
                 "item_last_update", "item_value"))

# create and assign dataset name
dsname <- paste0("us_evictions_",
                 stringr::str_sub(.[, min(item_year)],-2),
                 "_",
                 stringr::str_sub(.[, max(item_year)],-2)
                 )
assign(dsname, .)

# update database
schemaname <- "economic_wellbeing$housing"
con <- sdalr::con_db(dbname = "sdad", host = "localhost", port = 5433, pass = "Iwnftp$2")
DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", schemaname))
DBI::dbWriteTable(con, c(schemaname, dsname), ., overwrite = T, row.names = F)

