
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(DT)
library(shinythemes)
library(shinydashboard)


ui <- dashboardPage( 
  
  skin = "purple",
  dashboardHeader(title = "Exploring the OMDb API", titleWidth = 300),
  
  dashboardSidebar(
    width = 300,
    
    textInput('title1', "TV Series 1", placeholder = "Title"),
    uiOutput('season1'),
    uiOutput('include1'),
    
    textInput('title2', "TV Series 2", placeholder = "Title"),
    uiOutput('season2'),
    uiOutput('include2'),
    
    textInput('title3', "TV Series 3", placeholder = "Title"),
    uiOutput('season3'),
    uiOutput('include3')
  ),
  
  dashboardBody(
    
    tabsetPanel(
      
      type = 'tabs',
      
      
      tabPanel("Total Seasons", 
               box(background = "aqua", 
                   width = 5, 
                   solidHeader = TRUE,
                   dataTableOutput('table1', height = 300, width = 400)
               )
               #textOutput('test')
      ),
                                               
      tabPanel("Raw Data Table", 
               box(background = "yellow", 
                   width = 500, 
                   solidHeader = TRUE,
                   dataTableOutput('table2', height = 500)
                   
               )
      ),
                                               
      tabPanel("Seasonal Trends",
               box(background = "green", 
                   width = 500, 
                   solidHeader = TRUE,
                   plotOutput('plot1', height = 500)
               )
      ),
      
      tabPanel("Episodal Trends",
               box(background = "maroon", 
                   width = 500, 
                   solidHeader = TRUE,
                   plotOutput('plot2', height = 500)
               )
      )
    )
  )
)


shinyUI(ui)