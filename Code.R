

# IMDB API documentation: http://imdb.wemakesites.net/
# IMDB API base: http://imdb.wemakesites.net/api

# Libraries
library(httr)
library(jsonlite)
library(dplyr)

# Setup Variables
api.key <- 'bf63c176-faee-4e92-a71e-461dbad75ad5' # Necesary to access API

# ================================================= TEST PROGRAM =================================================
# Given an actor and a year, this program will print out all of the movies that the actor was in for that year

# Specify year(s) below
imdb.id <- 'nm0000115' # IMDB ID for actor Nicholas Cage
specific.year <- c(2017, 2016)

# Details about request to API
base <- 'http://imdb.wemakesites.net/api/'
endpoint <- imdb.id
query.parameters <- list(api_key = api.key)
# Resulting request looks like this: http://imdb.wemakesites.net/api/nm0000115?api_key=bf63c176-faee-4e92-a71e-461dbad75ad5

# Get response from API and convert to json
response <- GET(paste0(base, endpoint), query = query.parameters) # return code 200 (working)
body <- content(response, "text")
json <- fromJSON(body)

#names(json) # 'data' looks promising

data <- json$data # this is a list

actor.description <- data$description
all.movies <- data$filmography # this is a dataframe of all movies and their years

# Find movies for given year
movies.for.years <- all.movies %>% dplyr::filter(grepl(paste(specific.year, collapse = '|'), year))
movies.for.years <- movies.for.years$title

# Print movies in a vertical list
cat( paste('- ', movies.for.years, collapse = '\n') )











