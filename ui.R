ui <- dashboardPage(
  help = NULL,
  dark = NULL,
  header = dashboardHeader(
    actionButton(
      inputId = "update_countries_modal",
      label = "Data Preprocessing",
      style = "margin-left: 33px; position: absolute;",
      icon = icon("database")
    ),
    title = div(class = "custom-title", "Interactive Biodiversity Insights"),
    titleWidth = "100%"
  ),
  sidebar = dashboardSidebar(disable = TRUE),
  body = dashboardBody(
    useShinyjs(),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/styles.css"),
      tags$script(src = "js/custom.js")
    ),
    fluidPage(
      shinyjs::hidden(
        absolutePanel(
          id = "html_panel",
          div(
            class = "header",
            tags$b("Species in the selected area"),
            actionButton("close_list_occurences", "x")
          ), br(),
          shinycssloaders::withSpinner(uiOutput("species_area_list"), type = 8)
        )
      ),
      fluidRow(
        column(
          width = 4,
          bs4Card(
            title = "",
            width = 12,
            height = "auto",
            solidHeader = TRUE,
            collapsible = FALSE,
            div(
              class = "selector-container",
              span(
                class = "selector-text",
                p(
                  "This dashboard visualizes ", tags$b("biodiversity data"),
                  " with a focus on species occurrences",
                  " within a ", tags$b("selected area"), ". It includes an ",
                  "interactive map displaying the locations of ",
                  "species occurrences, allowing users to explore ",
                  "spatial patterns, spatial patterns as well as",
                  tags$b("other visualizations"), "."
                )
              )
            ),
            br(),
            pickerInput(
              "species_name", "Species Name",
              choices = species_name_choices,
              selected = species_name_choices,
              multiple = TRUE,
              options = list(
                `live-search` = TRUE,
                `actions-box` = TRUE,
                `selected-text-format` = "count",
                `count-selected-text` = "{0}/{1} species"
              ),
              choicesOpt = list(
                content = stringr::str_trunc(species_name_choices, width = 38)
              )
            ),
            pickerInput("year_filter", "Year(s)",
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
              "month_filter", "Month(s)",
              choices = month_choices,
              selected = month_choices,
              multiple = TRUE,
              options = list(
                `actions-box` = TRUE
              )
            ),
            actionButton(
              inputId = "filter_btn",
              label = "Filter Data",
              icon = icon("filter")
            ),
            uiOutput("num_occurrences", style = "padding-top: 15px;")
          )
        ),
        column(
          width = 8,
          bs4Card(
            title = "",
            width = 12,
            height = "auto",
            solidHeader = TRUE,
            collapsible = FALSE,
            div(
              class = "selector-container",
              span(
                class = "selector-text",
                p(
                  "Explore species observations with an",
                  "interactive map. Use the ",
                  tags$b("selector tool"), " to draw a specific area."
                )
              )
            ),
            div(
              id = "leaflet_map_container",
              shinycssloaders::withSpinner(
                leafletOutput("leaflet_map", height = "650px"),
                type = 8
              )
            ),
            uiOutput("leaflet_map_placeholder")
          )
        )
      ),
      fluidRow(
        column(
          width = 6,
          bs4Card(
            title = "",
            width = 12,
            height = "auto",
            solidHeader = TRUE,
            collapsible = FALSE,
            div(
              class = "selector-container",
              span(
                class = "selector-text plot_text",
                "Analyze species occurrences over time with an",
                "interactive line plot.", tags$b("Click on a specific year"),
                "to filter data on it, providing a detailed temporal analysis of",
                "species observationsZz"
              )
            ),
            div(
              id = "occurrences_year_container",
              shinycssloaders::withSpinner(
                highchartOutput("occurrences_year"), type = 8
              )
            ),
            uiOutput("occurrences_year_placeholder")
          )
        ),
        column(
          width = 6,
          bs4Card(
            title = "",
            width = 12,
            height = "auto",
            solidHeader = TRUE,
            collapsible = FALSE,
            div(
              class = "selector-container",
              span(
                class = "selector-text plot_text",
                "Examine species occurrences over time with an",
                "interactive bar plot.", tags$b("Click on a specific month"),
                "to filter data on it, providing a detailed temporal analysis of",
                "species observations."
              )
            ),
            div(
              id = "occurrences_month_container",
              shinycssloaders::withSpinner(
                highchartOutput("occurrences_month"), type = 8
              )
            ),
            uiOutput("occurrences_month_placeholder")
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          bs4Card(
            title = "",
            width = 12,
            height = "auto",
            solidHeader = TRUE,
            collapsible = FALSE,
            div(
              h3("Detailed Species Occurrences Data"),
              downloadButton("download_data", "Download Filtered Data"),
              DTOutput("filtered_data")
            )
          )
        )
      )
    )
  )
)
