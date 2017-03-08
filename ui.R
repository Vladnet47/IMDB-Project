
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(DT)

ui <- fluidPage(
  titlePanel("TV Show Trends Over Time - Exploring the OMDb API"),
  
  sidebarLayout(
    sidebarPanel(
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
    
    mainPanel(
      tabsetPanel(
        type = 'tabs',
        
        tabPanel("Table 1", 
                 dataTableOutput('table1')
                 #textOutput('test')
        ),
        
        tabPanel("Table 2", 
                 dataTableOutput('table2')
                 #textOutput('test')
        ),
        
        tabPanel("Graph",
                 plotOutput('plot')
        ),
        tabPanel("Graph 2",
                 plotOutput('plot2')
        )
      )
    )
  )
  
)

shinyUI(ui)