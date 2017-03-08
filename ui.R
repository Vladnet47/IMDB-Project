library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(DT)
library(shinythemes)
library(shinydashboard)

ui <- dashboardPage( skin = "purple",
  dashboardHeader(title = "Exploring the OMDb API", titleWidth = 300),
  dashboardSidebar(width = 300,
                   textInput('title', "TV Series", value = "Breaking Bad", placeholder = "Title"),
                   uiOutput('season.selection')),
  dashboardBody(tabsetPanel(
    type = 'tabs',
    
    
    tabPanel("Raw Data Table",
             box(background = "aqua", width = 500, solidHeader = TRUE,
             dataTableOutput('table', height = 500))
    ),
    
    tabPanel("Seasonal Trends",
             box(background = "yellow", width = 1000, height = 425, solidHeader = TRUE, 
                 plotOutput('plot'))
    ),
    tabPanel("Episodal Trends",
             box(background = "green", width = 1000, height = 425, solidHeader = TRUE, 
                 plotOutput('plot2'))
    ))
  
  
  
)
  
)

shinyUI(ui)