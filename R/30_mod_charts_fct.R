
# ------ * Plot line for temporal evolution in years ---------------------------
#' Create a line plot of occurrences by year
#' @param data A data table containing the data to be plotted.
#' @param ns for the name space
#' @return A plot object displaying the number of occurrences by years

plot_occurrences_year <- function(data, ns) {
  
  # Aggregate occurrences by year
  aggregated_data <- data[, .(count = .N), by = year][order(year)]
  
  # Plot the line
  hc <- hchart(
    aggregated_data,
    type = "line",
    hcaes(x = year, y = count),
    name = "Occurrences",
    showInLegend = TRUE,
    animation = FALSE,
    color = "#0199f9"
  ) |>
    hc_yAxis(title = list(text = "Occurrences")) |>
    hc_xAxis(title = list(text = NULL)) |>
    hc_legend(enabled = FALSE)

  hc$x$hc_opts$plotOptions$series$events$click <- JS(
    paste0(
      "function(event) {
        Shiny.onInputChange('",
        ns("year_click"),
        "', event.point.category);
      }"
    )
  )
  
  hc
}

# ------ * Plot bars for temporal evolution in months (aggregated) -------------
#' Create a bar plot of occurrences by month
#' @param data A data table containing the data to be plotted.
#' @param ns for the name space
#' @return A plot object displaying the number of occurrences by months

plot_occurrences_month <- function(data, ns) {
  
  # Aggregate occurrences by months
  aggregated_data <- data[, .(count = .N), by = month]
  
  # Plot the bars
  hc <- hchart(
    aggregated_data,
    type = "column",
    hcaes(x = month, y = count),
    name = "Occurrences",
    showInLegend = TRUE,
    animation = FALSE,
    color = "#0199f9"
  ) |>
    hc_yAxis(title = list(text = "Occurrences")) |>
    hc_xAxis(title = list(text = NULL), categories = month.name) |>
    # hc_plotOptions(column = list(groupPadding = 0, pointPadding = 0)) |>
    hc_legend(enabled = FALSE)
  hc$x$hc_opts$plotOptions$series$events$click <- JS(
    paste0(
      "function(event) {
        Shiny.onInputChange('",
        ns("month_click"),
        "', event.point.category);
      }"
    )
  )
  
  hc
}
