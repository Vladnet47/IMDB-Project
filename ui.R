library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(DT)

ui <- fluidPage(
  titlePanel("TV Show Trends Over Time - Exploring the OMDb API"),
  
  sidebarLayout(
    sidebarPanel(
      textInput('title', "TV Series", value = "Breaking Bad", placeholder = "Title"),
      uiOutput('season.selection')
    ),
    mainPanel(
      tabsetPanel(
        type = 'tabs',
        
        tabPanel("Table", 
                 dataTableOutput('table')
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