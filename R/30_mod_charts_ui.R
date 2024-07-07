
mod_charts_ui <- function(id) {
  
  ns <- NS(id)
  
  if (id == "charts_module_year") {
    # ------ * HC line output  for temporal evolution in years -----------------
    highchartOutput(ns("occurrences_year"))
  } else {
    # ------ * HC bars output for temporal evolution in months -----------------
    highchartOutput(ns("occurrences_month"))
  }

}
