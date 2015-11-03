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
                 box(id = "box.upload.adv", title = "Load Demo File", solidHeader = FALSE, collapsed = FALSE,
                     collapsible = TRUE, width = NULL, background = "light-blue",
                     actionButton('demo.button', 'Load Demo File', icon("table"))
                 ),
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
        title = tagList(shiny::icon("line-chart"), "Output"), 
        width = NULL,
        id = "tabset.result",
        tabPanel("Getting Started",
                h3("Steps for Getting Started"),
                tags$ol(
                   tags$li('Upload a csv file with rows as the decision making units (DMUs), and columns as the 
                           input(s)/output(s). Alternatively, click Load Demo File to load example data'),
                   tags$li('Uploaded data will be shown under the Data tab in the right Output panel'),
                   tags$li('Enter the following model parameters under the Model tab in the left Setup panel:',
                           tags$ol(type="a", tags$li(tags$b('DMU names:'), 'column with the names of the DMUs. If none selected, names will be assigned'),
                                   tags$li(tags$b('Input(s):'), 'column(s) with the input(s) or resources used by each DMU. If model has no inputs, select contant.one'),
                                   tags$li(tags$b('Output(s):'), 'column(s) with the output(s) or products of each DMU. If model has no outputs, select contant.one'),
                                   tags$li(tags$b('Returns to Scale:'), 'option of the following:',
                                           tags$ul(tags$li(tags$b('vrs:'), 'variable returns to scale, convexity and free disposability'),
                                                   tags$li(tags$b('crs:'), 'constant returns to scale, convexity and free disposability'),
                                                   tags$li(tags$b('drs:'), 'decreasing returns to scale, convexity, down-scaling and free disposability'),
                                                   tags$li(tags$b('irs:'), 'increasing returns to scale, (up-scaling, but not down-scaling), convexity and free disposability'))),
                                   tags$li(tags$b('Orientation:'), 'orientation of the DEA model - input-reduction (input) or output-augmentation (output)'),
                                   tags$li(tags$b('Maximise Radial Slacks:'), 'a secondary objective function of maximizing radial slacks to identify weakly efficient DMUs'),
                                   tags$li(tags$b('Report Dual Weights:'), 'reports back the dual weights (multipliers) for the inputs and outputs'),
                                   tags$li(tags$b('Round Efficiency Values:'), 'rounds efficiency values to 0 and 1 if close'),
                                   tags$li(tags$b('Secondary Objective Functions:'), 'enables an alternate secondary objective function based on lambda and the z argument'),
                                   tags$li(tags$b('Secondary z:'), 'only used when Secondary Objective Functions is min or max')
                            )
                    ),
                   tags$li('Once a variables have been selected, click the Run Model button'),
                   tags$li('Results will be shown under the Results tab in the right Output panel.')
                )
        ),
        tabPanel("DEA Introduction",
                 h3("DEA Introduction"),
                 p("Data Envelopment Analysis (DEA) was first formulated by Charnes et al. [1], 
                   which built on earlier work by Farrell [2]. DEA is non parametric linear programming 
                   approach used for evaluating the performance of a set of DMUs which convert multiple 
                   inputs into multiple outputs. It is useful for cases where the relationships between 
                   the inputs and outputs are complex or unknown and it does not require any prior 
                   assumptions. As opposed to regression, which fits a line through the center of the data, 
                   DEA creates a piecewise linear curve on top of the observations [3]."),
                 # br(),
                 h5("Formulation for an Input-Oriented Variable Returns to Scale (VRS) DEA model, including slack variables:"),
                 withMathJax(),
                 p("$$\\text{minimize  }\\theta$$
                   $$\\sum_{j=1}^{n} x_{i,j}\\lambda_j - \\theta x_{i,k} + s^x_i = 0 \\; \\forall i$$
                   $$\\sum_{j=1}^{n} y_{r,j}\\lambda_j - s^y_j =  y_{r,k} \\; \\forall r$$
                   $$\\text{subject to }\\sum_{j=1}^{n} \\lambda_j  = 1$$
                   $$\\lambda_j , s^x_i, s^y_r \\geq 0  \\; \\forall i, \\; r, \\; j$$"),
                 
                 h4("References"),
                 tags$ol(
                   tags$li('A. Charnes, W. W. Cooper, and E. Rhodes, “Measuring the efficiency of decision making units”, Eur. J. Oper. Res., vol. 2, no. 6, pp. 429–444, Nov. 1978'),
                   tags$li('M. J. Farrell, "The Measurement of Productive Efficiency", vol. 120, no. 3, pp. 253-290, 1957.'),
                   tags$li('W. W. Cooper, L. M. Seiford, and J. Zhu, "Handbook on Data Envelopment Analysis", 1st ed. Kluwer Academic Publishers, 2004.')
                 )
        ),
        tabPanel("Data", 
                 h3("Uploaded Data"),
                 dataTableOutput(outputId = "table.data")
        ),
        tabPanel("Result",
                 h3("Results"),
                 p("Description of Results:",
                 tags$ul(
                  tags$li("In an input-oriented model, efficiency (eff) < 1 indicates inefficiency."),
                  tags$li("In an output-oriented model, efficiency (eff) > 1 indicates inefficiency."),
                  tags$li("status1 and status2 reflect 'error' statuses (0 = no problem)."),
                  tags$li("lambda_dmu_i > 0 indicates that dmu_i is used in setting a 'target' for the other DMU."), 
                  tags$li("Column(s) for DMU's with all zero lambdas ar not shown in the table below, however they are included in the download."))),
                 # tags$li("Click the Download button below to download the results in csv format"))),
                 # br(),
                 tabBox(
                   # title = tagList(shiny::icon("table"), "Table"), 
                   width = NULL,
                   id = "tabset.result.sub",
                   tabPanel("Efficiency",
                            plotOutput("plot.eff", height = 500)    
                   ),
                   tabPanel("Lambda",
                            plotOutput("plot.lambda", height = 500)    
                   ),
                   tabPanel("Table",
                    downloadButton('download.result', 'Download'),
                    dataTableOutput(outputId = "table.result")
                   ))
        )
    )
  )    
)