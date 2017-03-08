# Libraries
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(DT)

# Base variables

base <- "http://www.omdbapi.com/"

# Base functions

# Takes the base URL and query parameters to return json
getJSON <- function(base, query.params) {
  response <- GET(base, query = query.params)
  
  if(response$status_code == 200) {
    body <- content(response, "text")
    json <- fromJSON(body)
    return(json)
  } else {
    return(NULL)
  }
}

getTotalSeasons <- function(show.name) {
  query <- list(t = show.name)
  json <- getJSON(base, query)
  
  if(is.null(json)) {
    return( -1 )
  } else {
    return(as.numeric(json$totalSeasons[]) )
  }
}

# MAIN SERVER FUNCTION
server <- function(input, output) {

  tv.series.info <- reactive({
    show.number <- c(1:3)
    show.name <- c("placeholder","placeholder","placeholder")
    total.seasons <- c(-1, -1, -1)

    for(current in show.number) {
      text.entry <- input[[paste0("title", current)]]
      
      if(text.entry != "") { # if the current text entry is not empty
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
  
  # Slider Widgets
  output$season1 <- renderUI({
    max.seasons <- tv.series.info()$total.seasons[1]
    if(max.seasons > -1) {
      sliderInput('season1', "Seasons", value = c(1, max.seasons), min = 1, max = max.seasons)
    }
  })
  
  output$season2 <- renderUI({
    max.seasons <- tv.series.info()$total.seasons[2]
    if(max.seasons > -1) {
      sliderInput('season2', "Seasons", value = c(1, max.seasons), min = 1, max = max.seasons)
    }
  })
  
  output$season3 <- renderUI({
    max.seasons <- tv.series.info()$total.seasons[3]
    if(max.seasons > -1) {
      sliderInput('season3', "Seasons", value = c(1, max.seasons), min = 1, max = max.seasons)
    }
  })
  
  # Checkbox Widgets
  output$include1 <- renderUI({
    show.name <- tv.series.info()$show.name[1]
    if(show.name != "placeholder") {
      checkboxInput('include1', "Include in Analysis", value = TRUE)
    }
  })
  
  output$include2 <- renderUI({
    show.name <- tv.series.info()$show.name[2]
    if(show.name != "placeholder") {
      checkboxInput('include2', "Include in Analysis", value = TRUE)
    }
  })
  
  output$include3 <- renderUI({
    show.name <- tv.series.info()$show.name[3]
    if(show.name != "placeholder") {
      checkboxInput('include3', "Include in Analysis", value = TRUE)
    }
  })
  
  output$table1 <- renderDataTable({
    formatStyle(datatable(tv.series.info(), rownames = FALSE), columns = c(1:7), color = "black", backgroundColor = "#99d6ff")
  })
  
  output$table2 <- renderDataTable({
    formatStyle(datatable(tv.series.episodes(), rownames = FALSE), columns = c(1:7), color = "black", backgroundColor = "#99d6ff")
  })
  
  output$plot1 <- renderPlot({
    graph <- ggplot(data = tv.series.episodes(), aes(x = Episode, y = imdbRating, color = factor(Season), group = factor(Season))) +
      geom_point(size = 3) +
      geom_line(size = 2)

    return(graph)
  })
  
  output$plot2 <- renderPlot({
    graph <- ggplot(data = tv.series.episodes(), aes(x = Episode.Chronological, y = imdbRating, color = Show, group = Show)) +
      geom_point() +
      geom_line() +
      geom_smooth(method = "lm", se = FALSE)
    
    return(graph)
  })
}



shinyServer(server)