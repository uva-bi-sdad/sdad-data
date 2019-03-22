fread_combine <- function(file_list) {
  for (f in file_list) {
    print(paste("Getting", f))
    file_data <- data.table::fread(f, colClasses = "character")
    file_data[, file_name := basename(f)]
    #browser()
    if (exists("dt_out") == FALSE) dt_out <- file_data
    else dt_out <- data.table::rbindlist(list(dt_out, file_data))
  }
  dt_out
}
