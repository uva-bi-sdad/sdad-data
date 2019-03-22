## Parameters

source("R/get_msha.R")

url <- "https://arlweb.msha.gov/OpenGovernmentData/OGIMSHA.asp"
baseurl <- "https://arlweb.msha.gov/OpenGovernmentData/"

mshalinks <- get_msha(baseurl, url)

destfile <- "/data/sdal_data/original/mining"

store_msha(mshalinks, destfile)

store_msha(mshalinks)

