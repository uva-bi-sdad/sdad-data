# Get Crime Hours
. <- sf::st_read(
  sdalr::con_db("sdal"),
  query = "select * from behavior.va_pl_spotcrime_cat_08_18 where crime_year in (2016, 2017, 2018)"
)
. <- .[, c("crime_hour", "crime_type")]
.$geometry <- NULL
data.table::setDT(.)
. <- .[crime_type != "Traffic/Parking Violations", ]
crime_hours <- .[, .N, list(crime_hour, crime_type)]


# Make Heatmap
library(plotly)

crimehour_heatmap <- plot_ly(
  y = crime_hours$crime_hour,
  x = crime_hours$crime_type,
  z = crime_hours$N,
  type = "heatmap"
) %>%
  layout(xaxis = list(type = "category"),
         yaxis = list(type = "numeric", dtick = 1))

crimehour_heatmap
