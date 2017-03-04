
ui <- fluidPage(
  titlePanel("Temporary Title"),
  
  sidebarLayout(
    sidebarPanel(
      textInput('title', "TV Series", value = "Breaking Bad", placeholder = "Title"),
      uiOutput('season.selection')
    ),
    mainPanel(
      tabsetPanel(
        type = 'tabs',
        
        tabPanel("Table", 
                 tableOutput('table')
        ),
        
        tabPanel("Graph",
                 plotOutput('plot')
        )
      )
    )
  )
  
)

shinyUI(ui)