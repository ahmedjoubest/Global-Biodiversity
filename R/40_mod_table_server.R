
mod_table_server <- function(
    id, filtered_data
) {moduleServer(id, function(input, output, session) {
  
  # ------ * Data Table rendering ----------------------------------------------
  output$filtered_data <- renderDT({
    
    data <- copy(filtered_data())
    
    # Modify the data table
    data[, occurrenceID := paste0(
      "<a href=", occurrenceID, ' target="_blank" style="color:#0099f9;">',
      occurrenceID, "</a>"
    )]
    
    # change column names while displaying
    setnames(
      data,
      c("specieName", "eventDate", "month", "year", "longitudeDecimal",
        "latitudeDecimal", "occurrenceID"),
      c("Species Names", "Observation Date", "Month", "Year",
        "Longitude", "Latitude", "Observation Link")
    )
    
    data[, accessURI := NULL]
    
    datatable(
      data,
      escape = FALSE,
      selection = "none",
      rownames = FALSE,
      class = list(stripe = FALSE),
      options = list(
        pageLength = 10,
        stripe = FALSE,
        dom = "ftrip"  # This controls the display of table elements
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
  
})}


