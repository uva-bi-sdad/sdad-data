## app.R ##
library(shinydashboard)
library(shiny.semantic)
library(leaflet)
library(rmapshaper)
#library(semantic.dashboard)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Widgets", icon = icon("th"), tabName = "widgets",
             badgeLabel = "new", badgeColor = "green")
  )
)

ui <- dashboardPage(
  dashboardHeader(title = "Basic dashboard"),
  sidebar,
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              h2("Dashboard tab content"),
              # Boxes need to be put in a row (or column)
              fluidRow(box(plotOutput("plot1", height = 250)),

                       box(
                         title = "Controls",
                         sliderInput("slider", "Number of observations:", 1, 100, 50)
                       ),

                       box(plotOutput("boxplot1", height = 250)),

                       box(leafletOutput("map"))
                       )
              ),

      tabItem(tabName = "widgets",
              h2("Widgets tab content")
      )
    )

  )
)

server <- function(input, output) {
  set.seed(122)
  histdata <- rnorm(500)

  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })

  data("mtcars")
  library(ggplot2)
  mtcars$am <- factor(mtcars$am,levels=c(0,1),
                      labels=c("Automatic","Manual"))
  output$boxplot1 <- renderPlot({
    ggplot(mtcars, aes(x = am, y = mpg)) +
      geom_boxplot() +
      xlab("gearbox") + ylab("Miles per gallon")
  })


 bg_data <- readRDS("bg_data.RDS")

  map_sf <- bg_data[bg_data$item_year == "2010", ]

  #* Create color pallette ----
  pal <- leaflet::colorBin(
    palette = "Greens",
    domain = 0:2000,
    bins = c(0, 1, 10, 100, 500, 1000, 1500, 2000, 10000, 100000),
    na.color = "#808080"
  )

  #* Set map items
  crops <-
    c(
      "corn",
      "soybeans",
      "alfalfa",
      "apples",
      "christmas_trees",
      "grass_pasture",
      "fallow_idle_cropland",
      "deciduous_forest",
      "evergreen_forest"
    )

  #* Create map ----
  m <- leaflet::leaflet() %>%
    addProviderTiles("CartoDB.Positron") %>%
    addMapPane("base_layers", zIndex = 410) %>%
    addMapPane("boundaries", zIndex = 420)

  #* Create Map Layers ----
  for (c in crops) {
    # create geo item labels
    labels <- lapply(
      paste(map_sf$NAMELSAD, "<br />",
            "tract:", substr(map_sf$GEOID, 6, 11), "<br />",
            "block group:", substr(map_sf$GEOID, 12, 12), "<br />",
            "crop:", c, "<br />",
            "measure:", map_sf$item_measure, "<br />",
            "value:", round(map_sf[, c][[1]], 2)
      ),
      htmltools::HTML
    )

    # block groups
    m <- addPolygons(m,
                     data = map_sf,
                     weight = 1,
                     color = "Silver",
                     fillOpacity = .6,
                     fillColor = ~ pal(get(c)),
                     label = labels,
                     group = c,
                     options = pathOptions(pane = "base_layers")
    )
  }

  # county lines
  m <- addPolylines(m,
                    data = ct,
                    weight = 1.5,
                    color = "Black",
                    opacity = 1,
                    group = "county borders",
                    options = pathOptions(pane = "boundaries")
  )

  #* Create Map Legend and Layers Control
  m <- addLegend(m,
                 data = map_sf,
                 position = "topleft",
                 pal = pal,
                 values = 0:100000,
                 title = "Acres",
                 opacity = 1
  ) %>%
    addLayersControl(baseGroups = crops,
                     overlayGroups = "county borders",
                     options = layersControlOptions(collapsed = FALSE)
    )
  output$map <- renderLeaflet(m)
}

shinyApp(ui, server)
