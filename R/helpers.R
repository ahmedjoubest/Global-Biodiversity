
#' Include No Data placeholder
#'
#' This placeholder is used in place of charts when there is nothing to display
#'
#' @text Text to display
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

# Function to generate panel list
species_list_pannel <- function(data) {
  # Make the data table unique by specieName,
  # keeping rows with non-empty accessURI
  data <- data[
    order(specieName, -nzchar(accessURI)), .SD[1], by = specieName
  ][order(-accessURI)] # show observation with images always first
  
  # Generate the TagList
  tagList(
    span(
      if (nrow(data) == 0) {
        "No Species in the selected Area."
      } else {
        tagList(
          actionButton(
            inputId = "filter_species_map",
            label = "Filter On species in the area",
            icon("filter")
          ),
          br(),
          br()
        )
      }
    ),
    lapply(
      seq_len(nrow(data)), function(i) {
        row <- data[i, ]
        div(
          class = "occurrence",
          div(
            a(
              href = row[["occurrenceID"]],
              class = "title",
              target = "_blank",
              row[["specieName"]]
            ),
            div(
              class = "subtext", span(row[["eventDate"]])
            )
          ),
          img(
            src = if (nchar(row[["accessURI"]]) > 1) {
              row[["accessURI"]]
            } else {
              "https://cdn1.iconfinder.com/data/icons/hotel-and-restaurant-volume-4/48/193-512.png"
            },
            alt = "Occurrence Image"
          )
        )
      }
    )
  )
}

data_preprocess <- function(countries = "PL") {
  
  # Put column name into variable, then filter by value,
  # then return the first line along with filtered lines
  unix_cmd <- paste0(
    "head -n 1 data/occurence.csv && grep -E ',(",
    paste0(countries, collapse = "|"), "),
  ' data/occurence.csv"
  )
  
  windows_cmd <- paste0(
    "powershell -Command \"Get-Content data\\occurence.csv -TotalCount 1\" && findstr \"",
    paste(paste0(",", countries, ","), collapse = " "),
    "\" data\\occurence.csv"
  )
  
  # pour select input, utiliser country & countryCode
  if (.Platform$OS.type == "windows") {
    cmd <- windows_cmd
  } else if (.Platform$OS.type == "unix") {
    cmd <- unix_cmd
  }
  
  cat("Reading occurences.csv ...")
  occurence_preprocessed <- fread(
    cmd = cmd, select = c("id",  "occurrenceID", "scientificName",
                          "vernacularName", "longitudeDecimal",
                          "latitudeDecimal", "eventDate")
  )
  
  # Concatenate names to one column 'specieName' and remove the old columns 
  occurence_preprocessed[,
                         specieName := ifelse(
                           vernacularName != "",
                           paste(scientificName, vernacularName, sep = " - "), 
                           scientificName
                         )
  ][, c("scientificName", "vernacularName") := NULL]
  
  cat("Reading multimedia.csv ...")
  # read multimedia
  multimedia <- fread("data/multimedia.csv", select = c("CoreId", "accessURI"))
  # For the sake of simplicity, we take only 1 picture by observation
  multimedia <- unique(multimedia, by = "CoreId")
  
  # Get observatinos pictures
  occurence_preprocessed_with_media <- data.table::merge.data.table(
    occurence_preprocessed, multimedia,
    by.x = "id", by.y = "CoreId",
    all.x = TRUE
  )
  
  # Get rid of "id" column
  occurence_preprocessed_with_media[, "id" := NULL]
  
  # Convert the eventDate column to Date type
  occurence_preprocessed_with_media[, eventDate := ymd(eventDate)]
  
  
  # Add month and year columns
  occurence_preprocessed_with_media[, month := format(eventDate, "%B")]
  occurence_preprocessed_with_media[, year := year(eventDate)]
  
  setcolorder(
    occurence_preprocessed_with_media,
    c(
      "specieName", "eventDate", "month", "year",
      "longitudeDecimal", "latitudeDecimal",
      "occurrenceID", "accessURI"
    )
  )
  cat("Writing occurences_preprocessed.csv ...")
  fwrite(occurence_preprocessed_with_media, "data/occurences_preprocessed.csv")
}
