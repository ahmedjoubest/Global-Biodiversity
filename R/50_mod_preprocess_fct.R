
# ------ * Data Pre-processing function ----------------------------------------
#' Data Pre-processing Helper Function
#'
#' Pre-processes occurrence data for specified countries by filtering and merging with multimedia data.
#' It handles differences in command syntax between Unix and Windows operating systems.
#' A pre-processed data.table combining occurrence and multimedia data, which is saved to a CSV file.
#'
#' @param countries A character vector of country codes to filter the occurrence data. Default is "PL".

data_preprocess <- function(countries = "PL") {
  
  # Unix and Windows pre-processing command
  unix_cmd <- paste0(
    "head -n 1 data/occurence.csv && grep -E ',\\s*(",
    paste0(countries, collapse = "|"), ")\\s*,' data/occurence.csv"
  )
  
  
  windows_cmd <- paste0(
    "powershell -Command \"Get-Content data\\occurence.csv -TotalCount 1\" && findstr \"",
    paste(paste0(",", countries, ","), collapse = " "),
    "\" data\\occurence.csv"
  )
  
  if (.Platform$OS.type == "windows") {
    cmd <- windows_cmd
  } else if (.Platform$OS.type == "unix") {
    cmd <- unix_cmd
  }
  
  # Read 'occurrence.csv' and reading it
  occurence_preprocessed <- fread(
    cmd = cmd, select = c("id",  "occurrenceID", "scientificName",
                          "vernacularName", "longitudeDecimal",
                          "latitudeDecimal", "eventDate")
  )
  
  occurence_preprocessed[,
                         specieName := ifelse(
                           vernacularName != "",
                           paste(scientificName, vernacularName, sep = " - "), 
                           scientificName
                         )
  ][, c("scientificName", "vernacularName") := NULL]
  
  # Read 'multimedia.csv'
  multimedia <- fread("data/multimedia.csv", select = c("CoreId", "accessURI"))
  # For the sake of simplicity, we take only 1 picture by observation
  multimedia <- unique(multimedia, by = "CoreId")

  # merge on id/CoreId
  occurence_preprocessed_with_media <- data.table::merge.data.table(
    occurence_preprocessed, multimedia,
    by.x = "id", by.y = "CoreId",
    all.x = TRUE
  )
  
  # Data preparation
  occurence_preprocessed_with_media[, "id" := NULL]
  occurence_preprocessed_with_media[, eventDate := ymd(eventDate)]
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
  
  # write the preprocessed data
  fwrite(occurence_preprocessed_with_media, "data/occurences_preprocessed.csv")
  
}
