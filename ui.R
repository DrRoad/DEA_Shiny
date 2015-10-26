# File:        ui.R
# Description: user Interface for Shiny Application
# Author:      Kevin van Blommestein

dashboardPage(skin = "blue",
  dashboardHeader(title = "Data Envelopment Analysis", titleWidth = 270),
  dashboardSidebar(width = 270,
    sidebarMenu(
      tabBox(
        width = NULL,
        id = "tabset.setup",
        title = tagList(shiny::icon("gear"), "Setup"),
        tabPanel("1.Data",
                 box(id = "box.upload.adv", title = "Upload File", solidHeader = FALSE, collapsed = FALSE,
                     collapsible = TRUE, width = NULL, background = "light-blue",
                     fileInput('file.upload', 'Choose CSV File', accept=opts$file$type),
                     tags$hr(),
                     selectInput('file.sep', 'Separator', opts$file$sep),
                     selectInput('file.quote', 'Quote', opts$file$quote),
                     checkboxInput('file.header', 'Column Header', TRUE)
                 )
        ),
        tabPanel("2.Model", 
                 box(id = "box.model.basic", title = "Basic Model Settings", solidHeader = FALSE, collapsed = FALSE,
                     collapsible = TRUE, width = NULL, background = "light-blue",
                     selectInput('model.dmus', 'DMU Names', 'none'),
                     selectInput('model.inputs', 'Input(s)', 'none', multiple = TRUE),
                     selectInput('model.outputs', 'Output(s)', 'none', multiple = TRUE),
                     selectInput('model.rts', 'Returns to Scale', opts$model$rts),
                     selectInput('model.orientation', 'Orientation', opts$model$orientation)
                 ),
                 box(id = "box.model.adv", title = "Advanced Model Settings", solidHeader = FALSE, collapsed = TRUE, 
                     collapsible = TRUE, width = NULL, background = "light-blue",
                     checkboxInput('model.slack', 'Maximize Radial Slacks', opts$model$slack),
                     checkboxInput('model.dual', 'Report Dual Weights', opts$model$dual),
                     checkboxInput('model.round', 'Round Efficiency Values', opts$model$round),
                     selectInput('model.second', 'Secondary Objective Function', opts$model$second),
                     selectInput('model.z', 'Secondary z', 'none')
                 ),
                 actionButton('model.button', 'Run Model', icon("dashboard"))
        )
      )
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabBox(
        title = tagList(shiny::icon("line-chart"), "Results"), 
        width = NULL,
        id = "tabset.result",
        tabPanel("Data Table", 
                 dataTableOutput(outputId = "table.data")
        ),
        tabPanel("Result",
                 downloadButton('download.result', 'Download'),
                 dataTableOutput(outputId = "table.result")
        )
    )
  )    
)