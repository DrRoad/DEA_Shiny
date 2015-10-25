## ui.R ##

dashboardPage(skin = "blue",
  dashboardHeader(title = "Data Envelopment Analysis", titleWidth = 250),
  dashboardSidebar(width = 250,
    sidebarMenu(
      h4("Setup"),
#       box(id = "box.upload", title = "Step 1 - Upload Data", solidHeader = TRUE, collapsible = TRUE, 
#           width = NULL, background = "black",
#           fileInput('file.upload', 'Choose CSV File', accept=opts$file$type),
#           # tags$hr(),
#           selectInput('file.sep', 'Separator', opts$file$sep),
#           selectInput('file.quote', 'Quote', opts$file$quote),
#           checkboxInput('file.header', 'Column Header', TRUE)),
#       box(id = "box.model", title = "Step 2 - Model Setup", solidHeader = TRUE, collapsed = TRUE, 
#           collapsible = TRUE, width = NULL, background = "black")
#      box(title = "View Results", solidHeader = TRUE, collapsed = TRUE, collapsible = TRUE),
      tabBox(
        # title = "Setup", 
        width = NULL,
        # The id lets us use input$tabset1 on the server to find the current tab
        id = "tabset.setup",
        tabPanel("Data",
                 fileInput('file.upload', 'Choose CSV File', accept=opts$file$type),
                 tags$hr(),
                 box(id = "box.upload.adv", title = "Advanced Settings", solidHeader = FALSE, collapsed = TRUE,
                     collapsible = TRUE, width = NULL,
                     selectInput('file.sep', 'Separator', opts$file$sep),
                     selectInput('file.quote', 'Quote', opts$file$quote),
                     checkboxInput('file.header', 'Column Header', TRUE)
                 )
        ),
        tabPanel("Model", 
                 box(id = "box.model.basic", title = "Basic Settings", solidHeader = FALSE, collapsed = FALSE,
                     collapsible = TRUE, width = NULL,
                     selectInput('model.dmus', 'DMU Names', 'none'),
                     selectInput('model.inputs', 'Input(s)', 'none', multiple = TRUE),
                     selectInput('model.outputs', 'Output(s)', 'none', multiple = TRUE),
                     selectInput('model.rts', 'Returns to Scale', opts$model$rts),
                     selectInput('model.orientation', 'Orientation', opts$model$orientation)
                 ),
                 box(id = "box.model.adv", title = "Advanced Settings", solidHeader = FALSE, collapsed = TRUE, 
                     collapsible = TRUE, width = NULL,
                     checkboxInput('model.slack', 'Maximize Radial Slacks', opts$model$slack),
                     checkboxInput('model.dual', 'Report Dual Weights', opts$model$dual),
                     checkboxInput('model.round', 'Round Efficiency Values', opts$model$round),
                     selectInput('model.second', 'Secondary Objective Function', opts$model$second),
                     selectInput('model.z', 'Secondary z', 'none')
                 ),
                 actionButton('model.button', 'Run Model', icon("dashboard"))
        )
      )
#       menuItem("Setup", tabName = "tab.setup", icon = icon("dashboard"),
#                menuSubItem("Upload Data", tabName = "tab.setup.upload"),
#                menuSubItem("Explore Data", tabName = "tab.setup.explore"),
#                menuSubItem("Create DEA Model", tabName = "tab.setup.model")),
#       menuItem("Results", tabName = "tab.result", icon = icon("th"),
#                menuSubItem("Result Summary", tabName = "tab.result.summary"),
#                menuSubItem("Result Detailed", tabName = "tab.result.detailed"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    h4("Results"),
    tabBox(
        # title = "Results", 
        width = NULL,
        id = "tabset.results",
        tabPanel("Data", 
                 dataTableOutput(outputId = "table.data")
        ),
        tabPanel("Result", 
                 dataTableOutput(outputId = "table.result")
        )
    )
  )    
)