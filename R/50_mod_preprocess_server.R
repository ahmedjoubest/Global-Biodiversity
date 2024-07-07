
mod_preprocess_server <- function(
    id
) { moduleServer(id, function(input, output, session) {
  
  ns <- session$ns
  
  # ------ * Open Modal Dialog on button ---------------------------------------
  observeEvent(input$update_countries_modal, {
    showModal(modalDialog(
      title = "Pre-process the Data",
      uiOutput(ns("modal_ui")),
      easyClose = TRUE,
      footer = modalButton("Close")
    ))
  })
  
  # ------ * Render Modal content ----------------------------------------------
  output$modal_ui <- renderUI({
    tagList(
      p("Here, you can pre-process the 'occurences.csv' file through the countries."),
      pickerInput(ns("countries"), "Countries", 
                  choices = countries, 
                  selected = "PL",
                  multiple = TRUE,
                  options = list(
                    `actions-box` = TRUE,
                    `live-search` = TRUE
                  )
      ),
      actionButton(
        inputId = ns("update_countries"),
        label = "Pre-process",
        icon = icon("cogs")
      )
    )
  })
  
  # ------ * Preprocess data ---------------------------------------------------
  observeEvent(input$update_countries, {
    # Trigger custom loading Pop-up
    shinyalert(
      text = div(
        class = 'cssload-loader',
        "The data is being pre-processed"
      ) |> as.character(),
      showConfirmButton = FALSE,
      html = TRUE,
      size = 'm'
    )
    # Data pre-processing function
    data_preprocess(input$countries)
    # Pop-up for successful pre-processing
    shinyalert(
      text = p("The data has been successfully pre-processed. Please refresh the page.") |> as.character(),
      type = "info",
      animation = "pop",
      showConfirmButton = TRUE,
      html = TRUE,
      closeOnClickOutside = T,
      closeOnEsc = T,
      immediate = T,
      session = session
    )
  })
})
}
