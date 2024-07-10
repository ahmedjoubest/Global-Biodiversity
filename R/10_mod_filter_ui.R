
mod_filter_ui <- function(
    id,
    month_choices,
    year_choices,
    species_name_choices
) {
  
  ns <- NS(id)
  
  # ------ * List of filters ---------------------------------------------------
  tagList(
    pickerInput(
      ns("species_name"),
      "Species Name",
      choices = species_name_choices,
      selected = species_name_choices,
      multiple = TRUE,
      options = list(
        `live-search` = TRUE,
        `actions-box` = TRUE,
        `selected-text-format` = "count",
        `count-selected-text` = "{0}/{1} species"
      )
    ),
    pickerInput(
      inputId = ns("year_filter"),
      label = "Year(s)",
      choices = year_choices,
      selected = year_choices,
      multiple = TRUE,
      options = list(
        `live-search` = TRUE,
        `actions-box` = TRUE,
        `selected-text-format` = "count",
        `count-selected-text` = "{0}/{1} years"
      )
    ),
    pickerInput(
      inputId = ns("month_filter"),
      label = "Month(s)",
      choices = month_choices,
      selected = month_choices,
      multiple = TRUE,
      options = list(`actions-box` = TRUE)
    ),
    # Filter button
    actionButton(
      inputId = ns("filter_btn"),
      label = "Filter Data",
      icon = icon("filter")
    ),
    # ------ * Total number of occurences --------------------------------------
    uiOutput(ns("num_occurrences"), style = "padding-top: 15px;")
  )
}
