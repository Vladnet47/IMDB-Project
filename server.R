
# Libraries
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)

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
    print("GET response is invalid")
    return(NULL)
  }
}

# MAIN SERVER FUNCTION
server <- function(input, output) {
  
  season.total <- reactive({
    query <- list(t = input$title)
    json <- getJSON(base, query)
    return(as.numeric(json$totalSeasons))
  })
  
  season.episodes <- reactive({
    range <- input$season[1]:input$season[2]
    result <- data.frame() # initialize result outside of loop
    
    # get information for each specified season and combines into single data frame
    for(season in range) {
      query <- list(t = input$title, Season = season)
      current <- getJSON(base, query)
      current <- current$Episodes %>% mutate(Season = rep.int(season, nrow(current$Episodes))) %>% # add season column
        select(Season, Episode, Title, Released, imdbRating, imdbID)
      current$Episode = as.numeric(current$Episode)
      current$imdbRating = as.numeric(current$imdbRating)
      result <- rbind(result, current, make.row.names = FALSE) # add information for each season to result
    }
    
    return(result)
  })
  
  output$season.selection <- renderUI({
    sliderInput('season', "Seasons", value = c(1,season.total()), min = 1, max = season.total())
  })
  
  output$table <- renderTable({
    return(season.episodes())
  })
  
  output$plot <- renderPlot({
    graph <- ggplot(data = season.episodes(), aes(x = Episode, y = imdbRating, color = factor(Season), group = factor(Season))) +
      geom_point() +
      geom_line()
    
    return(graph)
  })
  
}






shinyServer(server)