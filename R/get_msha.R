## Function

library(XML)
library(dplyr)
library(magrittr)
library(tibble)
library(stringr)

# question 1 - this looks for just the zips - should it look for metadata too?

get_msha <- function(baseurl, url)  {

  mshalinks <- xml2::read_html(url) # read tree

  mshalinks <- mshalinks %>% # pull in zip names
    rvest::html_nodes(., 'a') %>%
    rvest::html_attr(., 'href') %>%
    stringr::str_match(., "(.*zip$)") %>% #[,1]
    as.tibble() %>%
    filter(!is.na(V1)) %>%
    select(V1)

  colnames(mshalinks) <- c("name") # rename columns

  mshalinks <- mshalinks %>% # create zip links
    as.data.frame(col.names = "name") %>%
    mutate(link = paste0(baseurl, mshalinks$name))

  colnames(mshalinks) <- c("name", "link") # rename columns

  return(mshalinks)
}


store_msha <- function(links) {
  links = links %>%
    mutate(destfile = str_c('./data/sdal_data/original/mining/',
                            'msha_',
                            str_extract(string = link,
                                        pattern = '(?<=DataSets/).*(?=\\.zip$)'),
                            '.csv'))
  apply(X = links %>%
          select(link, destfile),
        MARGIN = 1,
        FUN = function(row) {
          print(row[2])
          dataplumbr::file.download_unzip2temp(row[1]) %>%
            data.table::fread() %>%
            data.table::fwrite(file = row[2])
        })
  }


# ####
# dataset_urls <-
#   data.table::data.table(
#     url = character(),
#     filename = character(),
#     destfile = character(),
#     tablename = character()
#   )
#
# ds_id <- "msha"
#
# for (i in 1:nrow(msha_mining_zip_urls)) {
#   dt_url <- data.table::data.table(
#     url = msha_mining_zip_urls$link[i],
#     filename = msha_mining_zip_urls$name[i],
#     destfile = paste0("data/", msha_mining_zip_urls$name[i]),
#     tablename = paste0("us_", ds_id, "_", gsub(
#       ".", "_", gsub(
#         ".txt",
#         "",
#         gsub(".gz", "", msha_mining_zip_urls$name[i], fixed = TRUE),
#         fixed = TRUE
#       ), fixed = TRUE
#     ))
#   )
#   dataset_urls <- data.table::rbindlist(list(dataset_urls, dt_url))
# }
#
# dataset_urls

# files <- lapply(mshalinks$link, )
#
# for (u in 2:nrow(msha_mining_zip_urls)) {
#   # Download and unzip to temp dir
#   print(paste("Downloading, Decompressing and Reading", dataset_urls[u, destfile]))
#   files <- dataplumbr::file.download_unzip2temp(dataset_urls$url[u])
#   # Load File
#   dt <- data.table::fread(files[1])
#   print(paste("Creating database table ", dataset_urls$tablename[u]))


  # con <- sdalr::con_db("sdal")
  # DBI::dbGetQuery(con, paste("CREATE SCHEMA IF NOT EXISTS", "mining"))
  # DBI::dbWriteTable(con, c("mining", dataset_urls$tablename[u]), dt, row.names = F, overwrite = T)







