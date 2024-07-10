ui <- dashboardPage(
  help = NULL,
  dark = NULL,
  
  # ------ Header & Sidebar ----------------------------------------------------
  header = dashboardHeader(
    mod_preprocess_ui("preprocess_module"),
    title = div(class = "custom-title", "Interactive Biodiversity Insights")
  ),
  
  sidebar = dashboardSidebar(disable = TRUE),
  body = dashboardBody(
    
    # ------ Scripts & styles --------------------------------------------------
    useShinyjs(),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/styles.css"),
      tags$script(src = "js/custom.js")
    ),
    fluidPage(
      fluidRow(
        # ------ Filters Card --------------------------------------------------
        column(
          width = 4,
          bs4Card(
            width = 12,
            height = "auto",
            collapsible = FALSE,
            div(
              class = "selector-container",
              span(
                class = "selector-text",
                p(
                  "This dashboard visualizes", tags$b("biodiversity data"),
                  "with a focus on species occurrences within a",
                  tags$b("selected area."), "It includes an",
                  "interactive map displaying the locations of",
                  "species occurrences, allowing users to explore",
                  "spatial patterns, spatial patterns as well as",
                  tags$b("other visualizations.")
                )
              )
            ),
            br(),
            mod_filter_ui(
              id = "filter_module",
              month_choices = month_choices,
              year_choices = year_choices,
              species_name_choices = species_name_choices
            )
          )
        ),
        # ------ Leaflet Card --------------------------------------------------
        column(
          width = 8,
          bs4Card(
            width = 12,
            height = "auto",
            collapsible = FALSE,
            div(
              class = "selector-container",
              span(
                class = "selector-text",
                p(
                  "Explore species observations with an interactive map. Use the",
                  tags$b("selector tool"), "to draw a specific area."
                )
              )
            ),
            div(
              id = "leaflet_map_container",
              shinycssloaders::withSpinner(
                mod_map_ui("map_module"),
                type = 8
              )
            ),
            # ------ * Render Leaflet Placeholder ------------------------------
            uiOutput("leaflet_map_placeholder")
          )
        )
      ),
      fluidRow(
        # ------ Line Chart Card -----------------------------------------------
        column(
          width = 6,
          bs4Card(
            width = 12,
            height = "auto",
            collapsible = FALSE,
            div(
              class = "selector-container",
              span(
                class = "selector-text plot_text",
                "Analyze species occurrences over time with an 
                interactive line plot.", tags$b("Click on a specific year"),
                "to filter data on it, providing a detailed temporal analysis of 
                species observations."
              )
            ),
            div(
              id = "occurrences_year_container",
              shinycssloaders::withSpinner(
                mod_charts_ui("charts_module_year"), type = 8
              )
            ),
            # ------ * Render Line Chart Placeholder ---------------------------
            uiOutput("occurrences_year_placeholder")
          )
        ),
        # ------ Bar Chart Card ------------------------------------------------
        column(
          width = 6,
          bs4Card(
            width = 12,
            height = "auto",
            collapsible = FALSE,
            div(
              class = "selector-container",
              span(
                class = "selector-text plot_text",
                "Examine species occurrences over time with an 
                interactive bar plot.", tags$b("Click on a specific month"),
                "to filter data on it, providing a detailed temporal analysis of 
                species observations."
              )
            ),
            div(
              id = "occurrences_month_container",
              shinycssloaders::withSpinner(
                mod_charts_ui("charts_module_month"), type = 8
              )
            ),
            # ------ * Render Bar Chart Placeholder ----------------------------
            uiOutput("occurrences_month_placeholder")
          )
        )
      ),
      # ------ Data Table Card -------------------------------------------------
      fluidRow(
        column(
          width = 12,
          bs4Card(
            width = 12,
            height = "auto",
            collapsible = FALSE,
            div(
              h3("Detailed Species Occurrences Data"),
              mod_table_ui("table_module")
            )
          )
        )
      )
    )
  )
)
