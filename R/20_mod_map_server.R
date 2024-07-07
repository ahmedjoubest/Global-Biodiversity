
mod_map_server <- function(
    id, filtered_data
) {moduleServer(id, function(input, output, session) {
  
  ns <- session$ns
  
  # ------ * Leaflet map output ------------------------------------------------
  output$leaflet_map <- renderLeaflet({
    req(nrow(filtered_data()) > 0)
    plot_map(data = filtered_data())
  })
  
  # ------ * On area selection event -------------------------------------------
  observeEvent(input$leaflet_map_draw_new_feature, {
    
    shinyjs::show(id = "html_panel")
    
    feature <- input$leaflet_map_draw_new_feature
    
    coords <- feature$geometry$coordinates[[1]]
    lng <- sapply(coords, function(coord) coord[[1]])
    lat <- sapply(coords, function(coord) coord[[2]])
    
    # Delete the drawn features
    remove_drawn_features(
      session = session,
      features = input$leaflet_map_draw_all_features$features,
      ns = ns
    )
    
    # Filter the data based on the rectangle coordinates
    in_polygon <- filtered_data()[
      longitudeDecimal >= min(lng) & longitudeDecimal <= max(lng) &
        latitudeDecimal >= min(lat) & latitudeDecimal <= max(lat)
    ]
    
    # update reacted value species selected in area
    session$userData$species_in_selected_area(
      unique(in_polygon$specieName)
    )
    
    # Display unique species names
    output$species_area_list <- renderUI({
      species_list_pannel(
        data = in_polygon,
        ns = ns
      )
    })
  })
  
  # ------ * Delete features and species list pannel after filtering -----------
  observeEvent(input$filter_species_map, {
    # Hide the species list panel
    shinyjs::hide(id = "html_panel")
    # Delete the drawn features
    remove_drawn_features(
      session = session,
      features = input$leaflet_map_draw_all_features$features,
      ns = ns
    )
    # Note: data processing is handled in mod_filter_server()
  })
  
  # Close occurrences lists and clear map when close button clicked
  observeEvent(input$close_list_occurences, {
    # Delete the drawn features
    remove_drawn_features(
      session = session,
      features = input$leaflet_map_draw_all_features$features,
      ns = ns
    )
    # Hide the occurrences list panel
    shinyjs::hide(id = "html_panel")
  })
  
  # Send reactive value to 10_mod_filter_server to bind clicking
  filter_species_map <- reactive(input$filter_species_map)
  
  return(filter_species_map)
  
})
}
