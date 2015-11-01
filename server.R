# File:        server.R
# Description: serve code for Shiny Application
# Author:      Kevin van Blommestein

server <- function(session, input, output) {

  # Reactive values run sections of code when they are changed
  reactiveData <- reactiveValues(df = data.frame(), 
                                 res = data.frame())
  
  # Load demo data if Load Demo File button pressed
  observe ({
    if (input$demo.button == 0)
      return(NULL)
    
    reactiveData$df <<- read.csv(paste0(getwd(), "/data/Martino_data.csv"))
    
    # If there is data in the file, change setup tab to Model Setup
    if (nrow(reactiveData$df) != 0) {
      # Find columns with only numeric values
      numeric.cols <- colnames(reactiveData$df)[sapply(reactiveData$df, is.numeric)]
      # Populate select inputs for creating model
      updateSelectInput(session, "model.dmus", "DMU Names", c("none", colnames(reactiveData$df)), selected = "Aircraft")
      updateSelectInput(session, "model.inputs", "Input(s)", c("constant.one", numeric.cols), selected = "constant.one")
      updateSelectInput(session, "model.outputs", "Output(s)", c("constant.one", numeric.cols), selected = c("Speed", "Payload"))
      updateSelectInput(session, "model.z", "Secondary z", c("none", numeric.cols))
      # Change to model setup and data tables tabs
      updateTabsetPanel(session, "tabset.setup", selected = "2.Model")
      updateTabsetPanel(session, "tabset.result", selected = "Data")
    }
  })
  
  # Load data when file select 
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
      updateTabsetPanel(session, "tabset.result", selected = "Data")
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
    
      # Prepare data for DEA analysis
      dmus <- input$model.dmus
      x <- input$model.inputs
      y <- input$model.outputs
      z <- input$model.z
      
      if ("constant.one" %in% x | length(x) == 0){
        x <- as.matrix(rep(1, nrow(reactiveData$df)), ncol = 1)
        colnames(x) <- "constant.x"
      }
      else
        x <- reactiveData$df[, x]
      
      if ("constant.one" %in% y | length(y) == 0) {
        y <- as.matrix(constant.y = rep(1, nrow(reactiveData$df)), ncol = 1)
        colnames(y) <- "constant.y"
      }
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
      # Run DEA analysis
      res <<- DEA(x = x, y = y, rts = input$model.rts, orientation = input$model.orientation, 
                  slack = input$model.slack, dual = input$model.dual,
                  second = input$model.second, z = z, round = input$model.round)
      
      res.df <- data.frame(dmu = rownames(res$eff), eff = res$eff, status1 = res$status1, 
                           status2 = res$status2, lambda = res$lambda)
      
      # Append slack variables if slack = TRUE
      if (input$model.slack){
        colnames(res$sx) <- paste0("slack.", colnames(res$sx))
        colnames(res$sy) <- paste0("slack.", colnames(res$sy))
        res.df <- data.frame(res.df, res$sx, res$sy)
      }
      # Append dual weights variables if dual = TRUE
      if (input$model.dual){
        colnames(res$vx) <- paste0("dual.v.", colnames(res$vx))
        colnames(res$uy) <- paste0("dual.u.", colnames(res$uy))
        res.df <- data.frame(res.df, res$vx, res$uy, dual.w = res$w) 
      }
      colnames(res.df) <- tolower(colnames(res.df))
      reactiveData$res <<- res.df
    })
  })
  
  # Display Result when result dataframe is populated after analysis finished
  output$table.result <- renderDataTable({
    if (nrow(reactiveData$res) == 0)
      return(NULL)
    
    zero.lambda <- c(FALSE, grepl("lambda", colnames(reactiveData$res[,-1])) & colSums(reactiveData$res[,-1]) == 0)
    reactiveData$res[,!zero.lambda]
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
  
  # Barplot of efficiencies
  output$plot.eff <- renderPlot({
    if (nrow(reactiveData$res) == 0)
      return(NULL)
    
    ggplot(reactiveData$res, aes(dmu, eff)) + geom_bar(stat = "identity", fill = "steelblue", color = "black") + 
    theme_bw() + ylab("Efficiency") + xlab("DMUs") + theme(axis.text.x = element_text(angle = 90, vjust = 0.4, hjust=1)) +
    geom_hline(x = 1, linetype = "dashed")  
  })
  
  # Plot lambda values as heatmap
  output$plot.lambda <- renderPlot({
    if (nrow(reactiveData$res) == 0)
      return(NULL)
    
    d.plot <- reactiveData$res %>% select(dmu, contains("lambda.")) %>% gather(dmu2, lambda, -dmu)
    ggplot(d.plot, aes(dmu, dmu2)) + geom_tile(aes(fill = lambda)) + 
    theme_bw() + ylab("DMU") + xlab("DMU") + theme(axis.text.x = element_text(angle = 90, vjust = 0.4, hjust=1))
  })
}