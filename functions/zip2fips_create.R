filepaths <- list.files("data/sdal_data/original/zip2fips/", full.names = T)

for (f in filepaths) {
  . <- readr::read_fwf(f, col_positions = readr::fwf_widths(c(5, 10, 2, 2, 2, 2, 2, 3, 25)), skip = 1,
                       col_types = readr::cols("c","c","c","c","c","c","c","c","c"))
  . <- .[, c(1, 7:9)]
  names(.) <- c("zip_code_5", "state", "countyfp", "countynm")
  assign(basename(f), unique(.))
}

for (o in ls(pattern = "zipcty")) {
  data.table::setDT(get(o))
  if(exists("fnl")) fnl <- data.table::rbindlist(list(fnl, get(o)))
  else fnl <- get(o)
}

DBI::dbWriteTable(sdalr::con_db("sdal"), "zips2fips", fnl)
