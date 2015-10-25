## server.R ##

server <- function(session, input, output) {

  df <- data.frame()
  res <- data.frame()
  
  output$table.result <- renderDataTable({
    if (input$model.button == 0 | nrow(df) == 0)
      return(NULL)
    
    isolate({
      dmus <- input$model.dmus
      x <- input$model.inputs
      y <- input$model.outputs
      z <- input$model.z
      
      if ("constant.1" %in% x | length(x) == 0)
        x <- as.matrix(rep(1, nrow(df)), ncol = 1)
      else
        x <- df[, x]
    
      if ("constant.1" %in% y | length(y) == 0)
        y <- as.matrix(rep(1, nrow(df)), ncol = 1)
      else
        y <- df[, y]
    
      if (z != "none")
        z <- df[, z]
      else 
        z <- 0
      
      if (!(dmus %in% x) & !(dmus %in% y) & (dmus != "none")) {
        rownames(x) <- df[, dmus]
        rownames(y) <- df[, dmus]
      }
  
      res <<- DEA(x = x, y = y, rts = input$model.rts, orientation = input$model.orientation, 
                  slack = input$model.slack, dual = input$model.dual,
                  second = input$model.second, z = z, round = input$model.round)
    
      res.df <- data.frame(dmu = rownames(res$eff), eff = res$eff, status1 = res$status1, 
                           status2 = res$status2, lambda = res$lambda)
      if (input$model.slack)
        res.df <- cbind(res.df, res$sx, res$sy)
      if (input$model.dual)
        res.df <- cbind(res.df, res$vx, res$uy, res$w)
      
    })
    updateTabsetPanel(session, "tabset.results", selected = "Result")
      
    return(res.df)
  }, options = list(pageLength = 10, scrollX=TRUE))
  
  # Show data
  output$table.data <- renderDataTable({
    in.file <- input$file.upload
    if (is.null(in.file))
      return(NULL)
    
    file.quote <- switch(input$file.quote, double = '"', single = "'", "")
    df <<- read.csv(in.file$datapath, header = input$file.header, sep = input$file.sep, 
                  quote = file.quote)
    
    # If there is data in the file, change setup tab to Model Setup
    if (nrow(df) != 0) {
      numeric.cols <- colnames(df)[sapply(df, is.numeric)]
      updateTabsetPanel(session, "tabset.setup", selected = "Model")
      updateSelectInput(session, "model.dmus", "DMU Names", c("none", colnames(df)), selected = "none")
      updateSelectInput(session, "model.inputs", "Input(s)", c("constant.1", numeric.cols), selected = "constant.1")
      updateSelectInput(session, "model.outputs", "Output(s)", c("constant.1", numeric.cols), selected = "constant.1")
      updateSelectInput(session, "model.z", "Secondary z", c("none", numeric.cols))
      return(df)
    }
    
  }, options = list(pageLength = 10, scrollX=TRUE))
}