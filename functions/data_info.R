## Data Info Object

make_data_info <-
  function(url = "",
           title = "",
           data_source = "",
           data_source_abrev = "",
           geo_type = "",
           containing_geo_name = "",
           containing_sub_geo_name = "",
           category = "",
           sub_category = "",
           by = "") {
    
    l <- formals(make_data_info)
    for (i in 1:length(l)) {
      l[i] <- get(names(l[i]))
    }
    
    l
  }





