
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
      p(
        "Here, you can pre-process the 'occurences.csv' file through the countries. ",
        "Please don't exceed 5-10 big countries. Check ",
        tags$a(href = "https://github.com/ahmedjoubest/Global-Biodiversity", 
               target = "_blank", "the readme"),
        " for more information about the performance."
      ),
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
    
    # Update the global enviremnent (quick fix)
    occurences <<- fread("data/occurences_preprocessed.csv")
    
    # Pop-up for successful pre-processing
    shinyalert(
      text = p(
        "The data has been successfully pre-processed. 
        The page will be refreshed in 5 seconds..."
      ) |> as.character(),
      type = "info",
      animation = "pop",
      showConfirmButton = TRUE,
      html = TRUE,
      closeOnClickOutside = T,
      closeOnEsc = T,
      immediate = T,
      session = session
    )
    
    Sys.sleep(5)
    
    # Refresh page
    session$reload()
  })
})
}
