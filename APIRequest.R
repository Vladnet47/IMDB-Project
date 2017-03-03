
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)

# API Documentation: http://www.omdbapi.com/
# API Endpoint: http://www.omdbapi.com/?

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

# Returns a dataframe of all episodes for given seasons
getEpisodes <- function(seasons) {
  result <- data.frame() # initialize result outside of loop
  
  # get information for each specified season and combines into single data frame
  for(season in seasons) {
    query <- list(t = tv.series, Season = season)
    current <- getJSON(base, query)
    current <- current$Episodes %>% mutate(Season = rep.int(season, nrow(current$Episodes))) %>% # add season column
      select(Season, Episode, Title, Released, imdbRating, imdbID)
    current$Episode = as.numeric(current$Episode)
    current$imdbRating = as.numeric(current$imdbRating)
    result <- rbind(result, current, make.row.names = FALSE) # add information for each season to result
  }
  
  return(result)
}



# Initialize variables

tv.series <- "Breaking Bad"
base <- "http://www.omdbapi.com/"


# Get information for entire TV series

query <- list(t = tv.series)
tv.series.info <- getJSON(base, query)
total.seasons <- as.numeric(tv.series.info$totalSeasons)


# Get information for each episode of TV series

tv.series.episodes <- getEpisodes(1:total.seasons)


# Graph episodes in each season vs their respective IMDB Rating

graph <- ggplot(tv.series.episodes, aes(x = Episode, 
                                        y = imdbRating, 
                                        color = factor(Season), 
                                        group = factor(Season))) +
  geom_point() +
  geom_line()

print(graph)



