##
## title: "air_pollution"
## author: "Cory Kim"
## date: "6/18/2018"
## output: html_document
##

library(dplyr)
library(dtplyr)
library(XML)

url <- "https://aqs.epa.gov/aqsweb/airdata/download_files.html"
scrape <- xml2::read_html(url)
scrape <- rvest::html_nodes(scrape,'a')
scrape <- rvest::html_attr(scrape, 'href')
scrape <- stringr::str_match(scrape, "(.*zip$)")
scrape <- scrape[!is.na(scrape)]
scrape <- scrape[c(0,5,10,15,20,25,30,35) + 276] # <- 276th zip file on the site
scrape

# If there is an error here, the website may have updated
# Change this testthat statement if file was changed.
testthat::expect_equal(scrape[1], "daily_88101_2018.zip")

baseurl <- "https://aqs.epa.gov/aqsweb/airdata/"

summary_test <- as.data.frame(scrape, col.names = "name") %>%
  mutate(link = paste0(baseurl, scrape))

colnames(summary_test) <- c("name", "link")

summary_test

dataset_urls <-
  data.table::data.table(
    url = character(),
    filename = character(),
    destfile = character(),
    tablename = character()
  )

ds_id <- "aqs"

for (i in 1:nrow(summary_test)) {
  dt_url <- data.table::data.table(
    url = summary_test$link[i],
    filename = summary_test$name[i],
    destfile = paste0("data/", summary_test$name[i]),
    tablename = paste0("us_", ds_id, "_", gsub(
      ".", "_", gsub(
        ".txt",
        "",
        gsub(".gz", "", summary_test$name[i], fixed = TRUE),
        fixed = TRUE
      ), fixed = TRUE
    ))
  )
  dataset_urls <- data.table::rbindlist(list(dataset_urls, dt_url))
}

dataset_urls

for (u in 1:nrow(summary_test)) {
  # Download and unzip to temp dir
  print(paste("Downloading, Decompressing and Reading", dataset_urls[u, destfile]))
  files <- dataplumbr::file.download_unzip2temp(dataset_urls$url[u])
  # Load File
  dt <- data.table::fread(files[1])
  #print(paste("Creating database table ", dataset_urls$tablename[u]))

  dt2 <- dt %>%
    filter((`State Name` %in% c('Virginia','Maryland','West Virginia',
                                'North Carolina','Tennessee','Kentucky')))

  x <- 2019 - u

  readr::write_csv(dt2, path = paste("~/git/sdal_data/data/sdal_data/original/air_quality/air_qual_", x,".csv", sep = ""),
                   append = FALSE)

}
