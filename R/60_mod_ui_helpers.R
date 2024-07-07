
#' Include No Data placeholder
#'
#' This placeholder is used in place of charts when there is nothing to display
#'
#' @text Text to display
#' @return a "No data" div to display

include_no_data_placeholder <- function(text) {
  div(
    class = "bg-light no-data",
    div(
      class = paste(
        "bg-white ms-5 mt-5 border-start h-100",
        "d-flex align-items-center justify-content-center"
      ),
      div(
        class = "no-data text-center fs-5 text-primary",
        style = "opacity: 0.5; font-family: Merriweather",
        tags$i(class = "fas fa-circle-exclamation",
               style = "font-size: 2.5rem; margin-bottom: 10px;"),
        p(
          class = "color blue",
          text
        )
      )
    )
  )
}
