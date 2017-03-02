
library(httr)
library(jsonlite)

# API Documentation: http://www.omdbapi.com/
# API Endpoint: http://www.omdbapi.com/?


# Takes the base URL and query parameters to return json
returnJSON <- function(base, query.params) {
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

# Initialize variables

tv.series <- "Breaking Bad"
base <- "http://www.omdbapi.com/"


# Get information for entire TV series

query <- list(t = tv.series)
tv.series.info <- returnJSON(base, query)
total.seasons <- as.numeric(tv.series.info$totalSeasons)


# Get information for each episode of TV series

tv.series.episodes <- data.frame() # initialize variable outside of for loop
for(season in 1:total.seasons) {
  query <- list(t = tv.series, Season = season)
  current <- returnJSON(base, query)
  current <- current$Episodes
  current$Episode <- paste0(season, ".", current$Episode) # add proper episode numbers (season.episode (1.5 instead of 5))
  tv.series.episodes <- rbind(tv.series.episodes, current, make.row.names = FALSE) # add new season to data frame each time
}



