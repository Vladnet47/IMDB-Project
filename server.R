
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
      if(!is.null(current$Episodes)){
      current <- current$Episodes %>% mutate(Season = rep.int(season, nrow(current$Episodes))) %>% # add season column
        select(Season, Episode, Title, Released, imdbRating, imdbID)
      current$Episode = round(as.numeric(current$Episode))
      current$imdbRating = as.numeric(current$imdbRating)
      result <- rbind(result, current, make.row.names = FALSE) # add information for each season to result
      } else{
        stop("That's Not A Real TV Show")
      }
    }
    row.count <- nrow(result)
    episode.number <- 1:row.count
    if(!is.null(result)){
    result <- mutate(result, Episode = episode.number)
    colnames(result)[2] <- "Season Episode #"
    colnames(result)[5] <- "Rating"
    colnames(result)[6] <- "IMDb ID"
    result$Episode <- as.integer(result[[2]])
    return(result)
    } else{
      stop("That's Not A Real TV Show")
    }
  })
  
  output$season.selection <- renderUI({
    sliderInput('season', "Seasons", value = c(1,season.total()), min = 1, max = season.total())
  })
  
  output$table <- renderDataTable({
    formatStyle(datatable(season.episodes(), rownames = FALSE), columns = c(1:7), color = "black", backgroundColor = "#99d6ff")
  })
  
  output$plot <- renderPlot({
    dataF <- season.episodes()
    Seasons <- factor(dataF$Season)
    graph <- ggplot(data = season.episodes(), aes(x = Episode, y = Rating, color = Seasons, group = factor(Season))) +
      geom_point(size = 3) +
      geom_line(size = 2)
    
    return(graph)
  })
  
  output$plot2 <- renderPlot({
    graph <- ggplot(data = season.episodes(), aes(x = Episode, y = Rating)) +
      geom_point() +
      geom_line() +
      geom_smooth(method = "lm", se = FALSE)
    
    return(graph)
  })
  
}






shinyServer(server)