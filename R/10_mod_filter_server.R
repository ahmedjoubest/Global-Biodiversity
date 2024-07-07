
mod_filter_server <- function(
    id, data, filter_species_map_btn, input_click_year, input_click_month
) {moduleServer(id, function(input, output, session) {
  
  # ------ * Init reactive values ----------------------------------------------
  species_selector <- reactiveVal(NULL)
  year_selector <- reactiveVal(NULL)
  month_selector <- reactiveVal(NULL)
  
  # Update reactive values with inputs
  observeEvent(list(input$species_name), species_selector(input$species_name))
  observeEvent(list(input$year_filter), year_selector(input$year_filter))
  observeEvent(list(input$month_filter), month_selector(input$month_filter))
  
  # ------ * reactive data to return -------------------------------------------
  filtered_data <- reactive({
    data <- data[
      specieName %in% species_selector() &
        year %in% year_selector() &
        month %in% month_selector()
    ]
    update_species_picker(session = session, data = data)
    data
  }) |>
    bindCache(
      species_selector(),
      month_selector(),
      year_selector(),
      cache = "session"
    ) |>
    bindEvent(input$filter_btn, ignoreNULL = FALSE)
  
  # ------ * Render Sum of Occurences ------------------------------------------
  output$num_occurrences <- renderUI({
    num_occurrences <- nrow(filtered_data())
    formatted_num <- formatC(num_occurrences, format = "d", big.mark = " ")
    p(
      "Number of species occurrences in the filtered data: ",
      tags$b(formatted_num, class = "n_occurence-text")
    )
  })
  
  # ------ * Automate Click filter button after area selection -----------------
  observeEvent(filter_species_map_btn(), {
    # Ensures server is updated before the client
    species_selector(
      session$userData$species_in_selected_area()
    )
    shinyjs::click("filter_btn")
  })
  
  # ------ * Automate Click filter button after line/bar chart click -----------
  # Update year input based on HC click
  observeEvent(input_click_year(), {
    updatePickerInput(session, "year_filter", selected = input_click_year())
    # Ensures server is updated before the client
    year_selector(input_click_year())
    shinyjs::click("filter_btn")
  })
  # Update month input based on HC click
  observeEvent(input_click_month(), {
    updatePickerInput(session, "month_filter", selected = input_click_month())
    # Ensures server is updated before the client
    month_selector(input_click_month())
    shinyjs::click("filter_btn")
  })
  
  return(filtered_data)
  
})
}
