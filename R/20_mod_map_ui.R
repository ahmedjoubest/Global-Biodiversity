
mod_map_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    # ------ * List of filters -------------------------------------------------
    leafletOutput(ns("leaflet_map"), height = "650px"),
    
    # ------ * Species list panel ----------------------------------------------
    shinyjs::hidden(
      absolutePanel(
        id = ns("html_panel"),
        div(
          class = "header",
          tags$b("Species in the selected area"),
          actionButton(
            inputId = ns("close_list_occurences"),
            label = "x"
          )
        ), br(),
        shinycssloaders::withSpinner(
          uiOutput(
            ns("species_area_list")
          ),
          type = 8
        )
      )
    )
  )
}