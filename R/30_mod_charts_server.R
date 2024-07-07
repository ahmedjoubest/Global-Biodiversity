
mod_charts_server <- function(
    id, filtered_data
) {moduleServer(id, function(input, output, session) {
  
  ns <- session$ns
  
  # ------ * render HC line for temporal evolution in years---------------------
  output$occurrences_year <- renderHighchart({
    req(nrow(filtered_data()) > 0)
    plot_occurrences_year(data = filtered_data(), ns = ns)
  })
  
  # ------ * render HC bars for temporal evolution in months -------------------
  output$occurrences_month <- renderHighchart({
    req(nrow(filtered_data()) > 0)
    plot_occurrences_month(data = filtered_data(), ns = ns)
  })
  
  # Send reactive value to 10_mod_filter_server to bind clicking
  if (id == "charts_module_year") {
    return(reactive(input$year_click))
  } else {
    return(reactive(input$month_click))
  }
  
})
}
