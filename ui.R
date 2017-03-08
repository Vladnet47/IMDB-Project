library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(DT)
library(shinythemes)

ui <- fluidPage(theme = shinytheme("flatly"),
  titlePanel("TV Show Trends Over Time - Exploring the OMDb API"),
  
  sidebarLayout(
    sidebarPanel(
      textInput('title', "TV Series", value = "Breaking Bad", placeholder = "Title"),
      uiOutput('season.selection')
    ),
    mainPanel(
      tabsetPanel(
        type = 'tabs',
        
        tabPanel("Raw Data Table", 
                 dataTableOutput('table')
        ),
        
        tabPanel("Seasonal Trends",
                 plotOutput('plot')
        ),
        tabPanel("Episodal Trends",
                 plotOutput('plot2')
        )
      )
    )
  )
  
)

shinyUI(ui)