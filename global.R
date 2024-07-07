
# Load necessary libraries
library(shiny)
library(shinyWidgets)
library(data.table)
library(highcharter)
library(DT)
library(leaflet)
library(leaflet.extras)
library(shinyjs)
library(bs4Dash)
library(echarts4r)
library(lubridate)
library(shinyalert)
library(stringr)

# Load the data
occurences <- fread("data/occurences_preprocessed.csv")

# Set locale to English
Sys.setlocale("LC_TIME", "C")

# List of unique values for filters
month_choices <- month.name
year_choices <- sort(unique(occurences$year))
species_name_choices <- sort(unique(occurences$specieName))

# list of countries with code country
countries <- readRDS("data/countries.rds")
