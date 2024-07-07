
# ------ * Updating species picker function ------------------------------------
#' Update species picker input in Shiny app
#' 
#' @param session The session object passed to the Shiny server function.
#' @param data The data.table containing species information.
#' 
#' @return Updates the species picker input with unique species names.

update_species_picker <- function(session, data) {
  updatePickerInput(
    session = session,
    inputId = "species_name",
    selected = unique(data$specieName)
  )
}
