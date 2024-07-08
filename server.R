
server <- function(input, output, session) {
  output$map <- renderLeaflet({
    map <- leaflet() |>
      addTiles() |>
      addProviderTiles("Stadia.AlidadeSmooth") |>
      addWMSTiles(
        "https://map.ahmedjou.com/service?", layers = "my",
        options = WMSTileOptions(format = "image/png", transparent = TRUE)
      )
  })
}
