
# ------ * Plot map function ---------------------------------------------------
#' Plot a map with heat map and withdrawing toolbar
#' 
#' @param data a data.Table containing 'longitudeDecimal' and 'latitudeDecimal'
#' 
#' @return a leaflet map

plot_map <- function(data) {
  
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
  
  # Calculate bounding box
  bounds <- data[, .(
    lng_min = min(longitudeDecimal),
    lng_max = max(longitudeDecimal),
    lat_min = min(latitudeDecimal),
    lat_max = max(latitudeDecimal)
  )]
  
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

# ------ * Generate Panel function ---------------------------------------------
#' Generate a panel list of species
#' @param data data.table containing 'specieName' and 'accessURI'
#' @param ns for the name space
#' #' 
#' @return a HTML code for a species panel list

species_list_pannel <- function(data, ns) {
  
  # Make the data table unique by specieName
  # & keeping rows with non-empty accessURI
  data <- data[
    order(specieName, -nzchar(accessURI)), .SD[1], by = specieName
  ][order(-accessURI)] # always show observation with images at the top
  
  # Generate the TagList
  tagList(
    span(
      if (nrow(data) == 0) {
        "No Species in the selected Area."
      } else {
        tagList(
          actionButton(
            inputId = ns("filter_species_map"),
            label = "Filter On species in the area",
            icon("filter")
          ),
          br(),
          br()
        )
      }
    ),
    lapply(
      seq_len(nrow(data)), function(i) {
        row <- data[i, ]
        div(
          class = "occurrence",
          div(
            a(
              href = row[["occurrenceID"]],
              class = "title",
              target = "_blank",
              row[["specieName"]]
            ),
            div(
              class = "subtext", span(row[["eventDate"]])
            )
          ),
          img(
            src = if (nchar(row[["accessURI"]]) > 1) {
              row[["accessURI"]]
            } else {
              "https://cdn1.iconfinder.com/data/icons/hotel-and-restaurant-volume-4/48/193-512.png"
            },
            alt = "Occurrence Image"
          )
        )
      }
    )
  )
}


# ------ * Remove drawn features function --------------------------------------
#' 
#' @param session Shiny session object
#' @param features List of drawn features to remove
#' @param ns name space

remove_drawn_features <- function(session, features, ns) {
  lapply(
    features,
    function(rectangle) {
      session$sendCustomMessage(
        "removeleaflet",
        list(elid = ns("leaflet_map"), layerid = rectangle$properties$`_leaflet_id`)
      )
    })
}
