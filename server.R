
server <- function(input, output, session) {
  
  # ------ * Init session data -------------------------------------------------
  observe({
    session$userData$species_in_selected_area <- reactiveVal(NULL)
  })
  
  # ------ * Reactive filtered data --------------------------------------------
  filtered_data <- mod_filter_server(
    id = "filter_module",
    data = occurences,
    filter_species_map_btn = mod_map_server,
    input_click_year = mod_charts_server_year,
    input_click_month = mod_charts_server_month
  )
  
  # ------ * leaflet map server ------------------------------------------------
  mod_map_server <- mod_map_server("map_module", filtered_data)
  
  # ------ * Charts: bars and line HC server -----------------------------------
  mod_charts_server_year <-  mod_charts_server("charts_module_year", filtered_data)
  mod_charts_server_month <-  mod_charts_server("charts_module_month", filtered_data)
  
  # ------ * DT display + Download server --------------------------------------
  mod_table_server("table_module", filtered_data)
  
  # ------ * Data Pre-processing server ----------------------------------------
  mod_preprocess_server("preprocess_module")
  
  # ------ * Plot Placeholder (for empty results) ------------------------------
  # Observe filtered data and toggle placeholders to handle empty results
  observe({
    # Check if there is no data
    if (nrow(filtered_data()) == 0) {
      shinyjs::show("leaflet_map_placeholder")
      shinyjs::show("occurrences_year_placeholder")
      shinyjs::show("occurrences_month_placeholder")
      shinyjs::hide("leaflet_map_container")
      shinyjs::hide("occurrences_year_container")
      shinyjs::hide("occurrences_month_container")
    } else {
      shinyjs::hide("leaflet_map_placeholder")
      shinyjs::hide("occurrences_year_placeholder")
      shinyjs::hide("occurrences_month_placeholder")
      shinyjs::show("leaflet_map_container")
      shinyjs::show("occurrences_year_container")
      shinyjs::show("occurrences_month_container")
    }
  })
  
  lapply(
    c(
      "leaflet_map_placeholder", 
      "occurrences_year_placeholder",
      "occurrences_month_placeholder"
    ),
    function(output_placeholder) {
      output[[output_placeholder]] <- renderUI({
        include_no_data_placeholder(
          "No data available for the selected filters."
        )
      })
    }
  )
  
}
