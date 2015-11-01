# File:        server.R
# Description: serve code for Shiny Application
# Author:      Kevin van Blommestein

server <- function(session, input, output) {

  # Reactive values run sections of code when they are changed
  reactiveData <- reactiveValues(df = data.frame(), 
                                 res = data.frame())
  
  observe ({
    if (input$demo.button == 0)
      return(NULL)
    
    reactiveData$df <<- read.csv(paste0(getwd(), "/data/Martino_data.csv"))
    
    # If there is data in the file, change setup tab to Model Setup
    if (nrow(reactiveData$df) != 0) {
      # Find columns with only numeric values
      numeric.cols <- colnames(reactiveData$df)[sapply(reactiveData$df, is.numeric)]
      # Populate select inputs for creating model
      updateSelectInput(session, "model.dmus", "DMU Names", c("none", colnames(reactiveData$df)), selected = "none")
      updateSelectInput(session, "model.inputs", "Input(s)", c("constant.one", numeric.cols), selected = "constant.one")
      updateSelectInput(session, "model.outputs", "Output(s)", c("constant.one", numeric.cols))
      updateSelectInput(session, "model.z", "Secondary z", c("none", numeric.cols))
      # Change to model setup and data tables tabs
      updateTabsetPanel(session, "tabset.setup", selected = "2.Model")
      updateTabsetPanel(session, "tabset.result", selected = "Data Table")
    }
  })
  
  # Wait for File to be Uploaded
  observe ({
    in.file <- input$file.upload
    if (is.null(in.file))
      return(NULL)
    
    file.quote <- switch(input$file.quote, double = '"', single = "'", "")
    reactiveData$df <<- read.csv(in.file$datapath, header = input$file.header, sep = input$file.sep, 
                                 quote = file.quote)
    
    # If there is data in the file, change setup tab to Model Setup
    if (nrow(reactiveData$df) != 0) {
      # Find columns with only numeric values
      numeric.cols <- colnames(reactiveData$df)[sapply(reactiveData$df, is.numeric)]
      # Populate select inputs for creating model
      updateSelectInput(session, "model.dmus", "DMU Names", c("none", colnames(reactiveData$df)), selected = "none")
      updateSelectInput(session, "model.inputs", "Input(s)", c("constant.one", numeric.cols), selected = "constant.one")
      updateSelectInput(session, "model.outputs", "Output(s)", c("constant.one", numeric.cols))
      updateSelectInput(session, "model.z", "Secondary z", c("none", numeric.cols))
      # Change to model setup and data tables tabs
      updateTabsetPanel(session, "tabset.setup", selected = "2.Model")
      updateTabsetPanel(session, "tabset.result", selected = "Data Table")
    }
  })
  
  # Wait for Run Model button to be pressed before running DEA analysis
  observe ({
    if (input$model.button == 0)
      return(NULL)
    
    isolate({
      if (nrow(reactiveData$df) == 0)
        return(NULL)
    
      updateTabsetPanel(session, "tabset.result", selected = "Result")
    
      dmus <- input$model.dmus
      x <- input$model.inputs
      y <- input$model.outputs
      z <- input$model.z
      
      if ("constant.one" %in% x | length(x) == 0)
        x <- as.matrix(rep(1, nrow(reactiveData$df)), ncol = 1)
      else
        x <- reactiveData$df[, x]
      
      if ("constant.one" %in% y | length(y) == 0)
        y <- as.matrix(rep(1, nrow(reactiveData$df)), ncol = 1)
      else
        y <- reactiveData$df[, y]
      
      if (z != "none")
        z <- reactiveData$df[, z]
      else 
        z <- 0
      
      if (!(dmus %in% x) & !(dmus %in% y) & (dmus != "none")) {
        rownames(x) <- reactiveData$df[, dmus]
        rownames(y) <- reactiveData$df[, dmus]
      }
      
      res <<- DEA(x = x, y = y, rts = input$model.rts, orientation = input$model.orientation, 
                  slack = input$model.slack, dual = input$model.dual,
                  second = input$model.second, z = z, round = input$model.round)
      
      res.df <- data.frame(dmu = rownames(res$eff), eff = res$eff, status1 = res$status1, 
                           status2 = res$status2, lambda = res$lambda)
      
      if (input$model.slack)
        res.df <- cbind(res.df, sx = res$sx, sy = res$sy)
      if (input$model.dual)
        res.df <- cbind(res.df, vx = res$vx, uy = res$uy, w = res$w)
      
      reactiveData$res <<- res.df
    })
  })
  
  # Display Result when result dataframe is populated after analysis finished
  output$table.result <- renderDataTable({
    reactiveData$res
  }, options = list(pageLength = 10, scrollX=TRUE))
  
  # Display data when file uploaded
  output$table.data <- renderDataTable({
    reactiveData$df
  }, options = list(pageLength = 10, scrollX=TRUE))
  
  # Download file when download button is pressed
  output$download.result <- downloadHandler(
      filename = function() { 'dea_result.csv' },
      content = function(file) {
        write.csv(reactiveData$res, file, row.names = FALSE)
      }
  )
}