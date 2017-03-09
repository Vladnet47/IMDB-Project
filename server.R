
# Libraries
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(DT)
library(plotly)

# Base variables
base <- "http://www.omdbapi.com/"

# MAIN SERVER FUNCTION
server <- function(input, output) {
  
  #=========================================== FUNCTIONS ===============================================
  
  getTotalSeasons <- function(show.name) {
    query <- list(t = show.name)
    json <- getJSON(base, query)
    
    if(is.null(json)) {
      return( -1 )
    } else {
      return(as.numeric(json$totalSeasons) )
    }
  }
  
  #Takes the base URL and query parameters to return json
  getJSON <- function(base, query.params) {
    response <- GET(base, query = query.params)
    body <- content(response, "text")
    json <- fromJSON(body)
    
    if(json$Response == "True") {
      return(json)
    }
    return(NULL)
  }
  
  checkTextEntry <- function(text.entry) {
    json <- getJSON(base, list(t = text.entry))
    
    if(!is.null(json) && json$Type == "series") {
      return( json$Title )
    } else {
      return( -1 )
    }
  }
  
  makeSeasonSelection <- function(index) {
    max.seasons <- tv.series.info()$total.seasons[index]
    if(max.seasons != -1) {
      sliderInput(paste0('season', index), "Seasons", value = c(1, max.seasons), min = 1, max = max.seasons)
    }
  }
  
  makeIncludeWidget <- function(index) {
    show.name <- tv.series.info()$show.name[index]
    if(show.name != "placeholder") {
      return( checkboxInput(paste0('include', index), "Include in Analysis", value = TRUE) )
    }
  }
  
  makeDataTable <- function(index){
    show.name <- tv.series.info()$show.name[index]
    if(show.name != "placeholder") {
      data <- tv.series.episodes() %>% filter(., Show == show.name) 
      colnames(data)[4] <- "Chronological Episode"
      colnames(data)[5] <- "Episode Title"
      colnames(data)[6] <- "IMDb Rating"
      formatStyle(datatable(data, rownames = FALSE), columns = c(1:7), color = "black", backgroundColor = "#99d6ff")
    }
  }
  
  makeSeasonGraph <- function(index) {
    show.name <- tv.series.info()$show.name[index]
    
    if(show.name != "placeholder") {
      data <- tv.series.episodes() %>% filter(Show == show.name)
      data$Season <- factor(data$Season)
      graph <- ggplot(data , aes(x = Episode, y = imdbRating, color = Season, group = Season)) +
        geom_point(size = 3) +
        geom_line(size = 2) +
        labs(x = "Episode Number", y = "IMDB Rating") +
        ggtitle(show.name)
      
      return( ggplotly(graph) )  
    }
  }
  
  #=========================================== DATA ===============================================
  
  tv.series.info <- reactive({
    show.number <- c(1:3)
    show.name <- c("placeholder","placeholder","placeholder")
    total.seasons <- c(-1, -1, -1)
    
    for(current in show.number) {
      text.entry <- checkTextEntry(input[[paste0("title", current)]])
      
      if(text.entry != -1) { # if the current text entry is not empty
        show.name[current] <- text.entry # replace placeholder with text entry
        total.seasons[current] <- getTotalSeasons(text.entry) # find total seasons for that text entry
      }
    }
    
    info <- data.frame(show.number, show.name, total.seasons, stringsAsFactors = FALSE)
    
    return( info )
  })
  
  tv.series.episodes <- reactive({
    
    # Initialize outside for loop
    all.episodes <- data.frame(stringsAsFactors = FALSE)
    
    # Show range is all shows that are not called 'placeholder'
    show.range <- tv.series.info()$show.number[tv.series.info()$show.name != "placeholder"]
    
    # Add information about each show to 'all.episodes'
    for(show in show.range) {
      
      # Check if 'Include in Analysis' is selected in UI
      if(input[[paste0('include', show)]] == TRUE) {

        # Initialize outside for loop
        show.episodes <- data.frame(stringsAsFactors = FALSE)
        
        # Season range is min-max of slider input for respective show
        season.range <- c(input[[paste0('season', show)]][1]:input[[paste0('season', show)]][2])
        
        # Add information about each season to 'show.episodes'
        for(season in season.range) {
          query <- list(t = tv.series.info()$show.name[tv.series.info()$show.number == show], Season = season)
          current.season <- getJSON(base, query)
          
          # Format json to display information about episodes
          current.season <- current.season$Episodes
          show.name <- tv.series.info()$show.name[show]
          total.episodes <- nrow(current.season)
          
          # Add columns for show
          current.season <- current.season %>% 
            mutate(Show = rep(show.name, times = total.episodes)) %>% 
            mutate(Season = rep.int(season, total.episodes))
          
          # Make episode and imdb rating numeric
          current.season$Episode = as.numeric(current.season$Episode)
          current.season$imdbRating = as.numeric(current.season$imdbRating)
          
          # Attach rows from current season to show dataframe
          show.episodes <- show.episodes %>% rbind(current.season, make.row.names = FALSE)
        }
        
        # Number episodes chronological
        show.episodes <- show.episodes %>% 
          mutate(Episode.Chronological = c(1:nrow(show.episodes))) %>% 
          select(Show, Season, Episode, Episode.Chronological, Title, imdbRating) # select useful columns
        
        # Attach rows from current show to overall dataframe
        all.episodes <- all.episodes %>% rbind(show.episodes, make.row.names = FALSE)
      }
    }
    
    return( all.episodes )
  })
  
  #=========================================== UI OUTPUTS ===============================================
  
  # Slider Widgets
  output$season1 <- renderUI({
    makeSeasonSelection(1)
  })
  output$season2 <- renderUI({
    makeSeasonSelection(2)
  })
  output$season3 <- renderUI({
    makeSeasonSelection(3)
  })
  
  # Checkbox Widgets
  output$include1 <- renderUI({
    makeIncludeWidget(1)
  })
  output$include2 <- renderUI({
    makeIncludeWidget(2)
  })
  output$include3 <- renderUI({
    makeIncludeWidget(3)
  })
  
  # Data Tables
  output$table1 <- renderDataTable({
    makeDataTable(1)
  })
  output$table2 <- renderDataTable({
    makeDataTable(2)
  })
  output$table3 <- renderDataTable({
    makeDataTable(3)
  })
  
  # Seasonal Plots
  output$seasonplot1 <- renderPlotly({
    makeSeasonGraph(1)
  })
  output$seasonplot2 <- renderPlotly({
    makeSeasonGraph(2)
  })
  output$seasonplot3 <- renderPlotly({
    makeSeasonGraph(3)
  })
  
  # Chronological Graph
  output$plot2 <- renderPlotly({
    graph <- ggplot(data = tv.series.episodes(), aes(x = Episode.Chronological, y = imdbRating, color = Show)) +
      geom_point() +
      geom_line() +
      labs(x = "Episodes Chronologically", y = "IMDB Rating") +
      geom_smooth(method = "lm", se = FALSE)
    
    return( ggplotly(graph) )
  })
}

shinyServer(server)