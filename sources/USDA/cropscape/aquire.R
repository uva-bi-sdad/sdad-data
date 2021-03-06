# AQUIRE DATA

# FUNCTIONS ----------------------------------------------
get_cdl_files <- function(states = c(51), years = c(2016), dir = "data/original/USDA_CDL/") {
  for (s in states) {
    for (y in years) {
      print(paste("getting", s, y))
      cdlTools::getCDL(s, y, ssl.verifypeer = F, location = dir)
    }
  }
  list.files(dir, full.names = T)
}

# SCRIPT ----------------------------------------------
#* Download and save CDL files ----
get_cdl_files(states = c(51), years = c(2016, 2017), dir = "data/original/USDA_CDL/")
