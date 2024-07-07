
server <- function(input, output, session) {
  
  # Reactive values for filters
  month_selector <- reactiveVal()
  year_selector <- reactiveVal()
  species_selector <- reactiveVal()
  species_in_selected_area <- reactiveVal()
  
  observeEvent(list(input$month_filter), month_selector(input$month_filter))
  observeEvent(list(input$year_filter), year_selector(input$year_filter))
  observeEvent(list(input$species_name), species_selector(input$species_name))
  
  # Define a reactive expression that triggers when the filter button is clicked
  filtered_data <- reactive({
    data <- occurences[
      month %in% month_selector() &
        year %in% year_selector() &
        specieName %in% species_selector()
    ]
    updatePickerInput(
      session, "species_name", selected = unique(data$specieName)
    )
    data
  }) |>
    bindCache(
      species_selector(), month_selector(), year_selector(), cache = "session"
    ) |>
    bindEvent(input$filter_btn, ignoreNULL = FALSE)
  
  # ------ * Leaflet map -------------------------------------------------------
  
  # Render Leaflet Map
  output$leaflet_map <- renderLeaflet({
    req(nrow(filtered_data()) > 0)
    plot_map(data = filtered_data())
  })
  
  # Update data after filtering it using the selector
  observeEvent(input$filter_species_map, {
    # Ensures server is updated before the client
    species_selector(species_in_selected_area())
    shinyjs::click("filter_btn")
    # Hide the occurrences list panel
    shinyjs::hide(id = "html_panel")
  })
  
  # On area selection
  observeEvent(input$leaflet_map_draw_new_feature, {
    
    shinyjs::show(id = "html_panel")
    
    feature <- input$leaflet_map_draw_new_feature
    
    coords <- feature$geometry$coordinates[[1]]
    lng <- sapply(coords, function(coord) coord[[1]])
    lat <- sapply(coords, function(coord) coord[[2]])
    
    # Delete the drawn features
    remove_drawn_features(
      session = session,
      features = input$leaflet_map_draw_all_features$features
    )
    
    # Filter the data based on the rectangle coordinates
    in_polygon <- filtered_data()[
      longitudeDecimal >= min(lng) & longitudeDecimal <= max(lng) &
        latitudeDecimal >= min(lat) & latitudeDecimal <= max(lat)
    ]
    
    # update reacted value species selected in area
    species_in_selected_area(unique(in_polygon$specieName))
    
    # Display unique species names
    output$species_area_list <- renderUI({
      species_list_pannel(
        data = in_polygon
      )
    })
  })
  
  # Close occurrences lists and clear map when close button clicked
  observeEvent(input$close_list_occurences, {
    # Delete the drawn features
    remove_drawn_features(
      session = session,
      features = input$leaflet_map_draw_all_features$features
    )
    # Hide the occurrences list panel
    shinyjs::hide(id = "html_panel")
  })
  
  # ------ * Bar Chart ---------------------------------------------------------
  
  # Render Bar Chart
  output$occurrences_month <- renderHighchart({
    req(nrow(filtered_data()) > 0)
    plot_occurrences_month(filtered_data())
  })
  
  # Update month input based on highchart click
  observeEvent(input$month_click, {
    updatePickerInput(session, "month_filter", selected = input$month_click)
    # Ensures server is updated before the client
    month_selector(input$month_click)
    shinyjs::click("filter_btn")
  })
  
  # ------ * Line Chart --------------------------------------------------------
  
  # Render Line Chart
  output$occurrences_year <- renderHighchart({
    req(nrow(filtered_data()) > 0)
    plot_occurrences_year(filtered_data())
  })
  
  # Update year input based on highchart click
  observeEvent(input$year_click, {
    updatePickerInput(session, "year_filter", selected = input$year_click)
    # Ensures server is updated before the client
    year_selector(input$year_click)
    shinyjs::click("filter_btn")
  })
  
  # ------ * Data Table --------------------------------------------------------
  
  # Render the data table
  output$filtered_data <- renderDT({
    data <- copy(filtered_data())
    # Modify the data table
    data[, occurrenceID := paste0(
      '<a href="', occurrenceID, '" target="_blank" style="color:#0099f9;">',
      occurrenceID,'</a>'
    )]
    setnames(
      data,
      c("specieName", "eventDate", "month", "year", "longitudeDecimal",
        "latitudeDecimal", "occurrenceID"),
      c("Species Names", "Observation Date", "Month", "Year",
        "Longitude", "Latitude", "Observation Link")
    )
    data <- data[, .SD, .SDcols = !c("accessURI")]
    
    datatable(
      data,
      escape = FALSE,
      selection = 'none',
      rownames = FALSE,
      class = list(stripe = FALSE),
      options = list(
        pageLength = 10,
        stripe = FALSE,
        dom = 'ftrip'  # This controls the display of table elements
      )
    )
  })
  
  # ------ * Download Data -----------------------------------------------------
  
  # Download filtered data
  output$download_data <- downloadHandler(
    filename = function() {
      paste("filtered_data",".csv", sep = "")
    },
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    })
  
  # ------ * Plot Placeholder --------------------------------------------------
  
  # Observe filtered data and toggle placeholders
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
  
  # ------ * Adapt PickerWidth -------------------------------------------------
  
  observe({
    session$sendCustomMessage('setPickerWidth', list(id = "species_name"))
  })
  
  # ------ * Data Preprocessing ------------------------------------------------
  
  # Launch pre-processing modal
  observeEvent(input$update_countries_modal, {
    showModal(modalDialog(
      title = "Pre-process the Data",
      uiOutput("modal_ui"),
      easyClose = TRUE,
      footer = modalButton("Close")
    ))
  })
  
  # Content for the modal
  output$modal_ui <- renderUI({
    tagList(
      p("Here, you can pre-process the 'occurences.csv' 
        file through the countries."),
      pickerInput("countries", "Countries", 
                  choices = countries, 
                  selected = "PL",
                  multiple = TRUE,
                  options = list(
                    `actions-box` = TRUE,
                    `live-search` = TRUE
                  )
      ),
      actionButton(
        inputId = "update_countries",
        label = "Pre-process",
        icon = icon("cogs")
      )
    )
  })
  
  observeEvent(input$update_countries, {
    # loading pop-up
    shinyalert(
      text = div(
        class = 'cssload-loader',
        "The data is being pre-processed"
      ) |> as.character(),
      showConfirmButton = FALSE,
      html = TRUE,
      size = 'm'
    )
    # update data depending on countries
    data_preprocess(input$countries)
    # Data Sucessfully pre-processed
    shinyalert(
      text = p("The data has been successfully pre-processed") |> as.character(),
      type = "info",
      animation = "pop",
      showConfirmButton = TRUE,
      html = TRUE,
      closeOnClickOutside = T,
      closeOnEsc = T,
      immediate = T,
      session = session
    )
  })
  
  # ------ * Render Sum of Occurences ------------------------------------------
  output$num_occurrences <- renderUI({
    num_occurrences <- nrow(filtered_data())
    formatted_num <- formatC(num_occurrences, format = "d", big.mark = " ")
    p(
      "Number of species occurrences in the filtered data: ",
      tags$b(formatted_num, class = "n_occurence-text")
    )
  })
}
