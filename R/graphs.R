
#' Create a line plot of occurrences by year
#' @param data A data table containing the data to be plotted.
#' @return A plot object displaying the number of occurrences by years
plot_occurrences_year <- function(data) {
  
  # Aggregate occurrences by year
  aggregated_data <- data[, .(count = .N), by = year][order(year)]
  # Plot the line
  hc <- hchart(
    aggregated_data,
    type = "line",
    hcaes(x = year, y = count),
    name = "Occurrences",
    showInLegend = TRUE,
    animation = FALSE,
    color = "#0199f9"
  ) |>
    hc_yAxis(title = list(text = "Occurrences")) |>
    hc_xAxis(title = list(text = NULL)) |>
    hc_legend(enabled = FALSE)
  
  hc$x$hc_opts$plotOptions$series$events$click <- JS(
    "function(event) {
        Shiny.onInputChange('year_click', event.point.category);
      }"
  )
  hc
}

#' Create a bar plot of occurrences by month
#' @param data A data table containing the data to be plotted.
#' @return A plot object displaying the number of occurrences by months
plot_occurrences_month <- function(data) {
  # Aggregate occurrences by months
  aggregated_data <- data[, .(count = .N), by = month]
  # Plot the bars
  hc <- hchart(
    aggregated_data,
    type = "column",
    hcaes(x = month, y = count),
    name = "Occurrences",
    showInLegend = TRUE,
    animation = FALSE,
    color = "#0199f9"
  ) |>
    hc_yAxis(title = list(text = "Occurrences")) |>
    hc_xAxis(title = list(text = NULL), categories = month.name) |>
    # hc_plotOptions(column = list(groupPadding = 0, pointPadding = 0)) |>
    hc_legend(enabled = FALSE)
  hc$x$hc_opts$plotOptions$series$events$click <- JS(
    "function(event) {
        Shiny.onInputChange('month_click', event.point.category);
      }"
  )
  hc
}

# Plot map function
plot_map <- function(data = data) {
  
  # Calculate bounding box
  bounds <- data[, .(
    lng_min = min(longitudeDecimal),
    lng_max = max(longitudeDecimal),
    lat_min = min(latitudeDecimal),
    lat_max = max(latitudeDecimal)
  )]
  
  # Create the leaflet map
  map <- leaflet(data = data) |>
    addTiles() |>
    addProviderTiles("Stadia.AlidadeSmooth") |>
    addHeatmap(
      lng = ~longitudeDecimal,
      lat = ~latitudeDecimal,
      radius = 9,
      blur = 2,
      minOpacity = 0.3,
      max = 0.8,
      gradient = c("#30b864", "#0099f9")
    ) |>
    addDrawToolbar(
      targetGroup = "draw",
      polylineOptions = FALSE,
      polygonOptions = FALSE,
      circleOptions = FALSE,
      markerOptions = FALSE,
      circleMarkerOptions = FALSE,
      rectangleOptions = TRUE,
      editOptions = FALSE
    )
  
  # Set view based on number of points
  if (nrow(data) == 1) {
    map <- map |> setView(
      lng = data$longitudeDecimal, lat = data$latitudeDecimal, zoom = 10
    )
  } else {
    map <- map |> fitBounds(
      lng1 = bounds$lng_min,
      lng2 = bounds$lng_max,
      lat1 = bounds$lat_min,
      lat2 = bounds$lat_max
    )
  }
  map
}

# Delete drawn rectangles function
remove_drawn_features <- function(session, features) {
  lapply(
    features,
    function(rectangle) {
      session$sendCustomMessage(
        "removeleaflet",
        list(elid = "leaflet_map", layerid = rectangle$properties$`_leaflet_id`)
      )
    })
}
