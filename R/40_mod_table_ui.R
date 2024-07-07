
mod_table_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    # ------ * Data Download Button --------------------------------------------
    downloadButton(ns("download_data"), "Download Filtered Data"),
    # ------ * Data Table rendering --------------------------------------------
    DTOutput(ns("filtered_data"))
  )
}
