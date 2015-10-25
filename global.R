library(shiny)
library(shinydashboard)
library(TFDEA)

# Options used through code
opts <- list()
# options for uploaded files
opts$file$sep <- c(Comma=',', Semicolon=';', Tab='\t')
opts$file$type <- c('text/csv', 'text/comma-separated-values,text/plain', '.csv')
opts$file$quote <- c(None = 'none', 'Double Quote' = 'double', 'Single_Quote' = 'single')

# Options/Defaults for model
opts$model$rts <- c('vrs' , 'crs', 'drs', 'irs')
opts$model$orientation <- c('input', 'output')
opts$model$slack <- TRUE
opts$model$dual <- FALSE
opts$model$round <- FALSE
opts$model$second <- c('none', 'min', 'max')
