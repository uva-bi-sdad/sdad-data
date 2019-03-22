library(shiny)
library(semantic.dashboard)
library(shiny.semantic)
library(ggplot2)
library(plotly)
library(leaflet)

ui <- dashboardPage(
  dashboardHeader(color = "blue", title = "Dashboard Demo", inverted = TRUE),
  dashboardSidebar(
    color = "teal",
    sidebarMenu(
      menuItem(tabName = "main", "Main", icon = icon("car")),
      menuItem(tabName = "data", "Data", icon = icon("table")),
      menuItem(tabName = "map", "Map", icon = icon("globe"))
    )
  ),
  dashboardBody(
    tabItems(
      selected = 1,
      tabItem(
        tabName = "main",
        fluidRow(
          box(title = "Graph 1",
              color = "green", ribbon = TRUE, title_side = "top right",
              column(8,
                     plotOutput("boxplot1")
              )
          ),
          box(title = "Graph 2",
              color = "red", ribbon = TRUE, title_side = "top right",
              column(width = 8,
                     plotlyOutput("dotplot1")
              )
          )
        )
      ),
      tabItem(
        tabName = "data",
        fluidRow(
          dataTableOutput("carstable")
        )
      ),
      tabItem(
        tabName = "map",

        fluidRow(
          box(width = 4, title = "Map Control",
              dropdown("dd1",
                       choices = c("ALL", "DRUNK", "BURGLARY"),
                       choices_value = c("ALL", "DRUNK", "BURGLARY"),
                       default_text = "Select",
                       value = "ALL")
          )),
        fluidRow(column(6,
                        box(width = 6,
                            title = "Arlington Crime",
                            color = "red", ribbon = TRUE,
                            leafletOutput("map")
                            )
                        ),
                 column(6,
                        box(width = 6,
                            title = "Arlington Crime",
                            color = "red", ribbon = TRUE,
                            leafletOutput("map2")
                            )
                        )
        )
      )
    )
  ), theme = "cerulean"
)


server <- shinyServer(function(input, output, session) {
  library(data.table)
  library(sf)
  # ggplot
  data("mtcars")
  mtcars$am <- factor(mtcars$am,levels=c(0,1),
                      labels=c("Automatic","Manual"))
  output$boxplot1 <- renderPlot({
    ggplot(mtcars, aes(x = am, y = mpg)) +
      geom_boxplot(fill = semantic_palette[["green"]]) +
      xlab("gearbox") + ylab("Miles per gallon")
  })

  # plotly
  colscale <- c(semantic_palette[["red"]], semantic_palette[["green"]], semantic_palette[["blue"]])
  output$dotplot1 <- renderPlotly({
    ggplotly(ggplot(mtcars, aes(wt, mpg))
             + geom_point(aes(colour=factor(cyl), size = qsec))
             + scale_colour_manual(values = colscale)
    )
  })

  # DT
  output$carstable <- renderDataTable(mtcars)

  # leaflet
  #crime_data <- fread("crime data.csv")

  observeEvent(input$dd1, {
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
        "christmas_trees",
        "fallow_idle_cropland",
        "deciduous_forest"
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
    output$map2 <- renderLeaflet(m)
  })
})

shinyApp(ui, server)
