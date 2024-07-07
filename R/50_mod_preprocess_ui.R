
mod_preprocess_ui <- function(id) {
  
  ns <- NS(id)
  
  # ------ * Bbutton to launch -------------------------------------------------
  actionButton(
    inputId = ns("update_countries_modal"),
    label = "Data Preprocessing",
    style = "margin-left: 33px; position: absolute;",
    icon = icon("database")
  )
}
