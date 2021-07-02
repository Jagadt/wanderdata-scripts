require(jsonlite)
require(maptools)
require(ggmap)
require(dplyr)
require(tidyr)
require(bbplot)
require(lubridate)
require(parsedate)

df <- fromJSON('~/Development/wanderdata-scripts/swarmapp/data/checkins.json')

# json to dataframe
df <- flatten(df)

# create a new category column by select the category from the nested structure 'venue.category'
df$category <- sapply(df$venue.categories, function(x) x$name)
df$posixct <- parsedate::parse_date(df$createdAt)
df$date <- date(df$posixct)
df$hour <- hour(df$posixct)

coordinates <- data.frame(id = df$venue.id, lat = df$venue.location.lat, lon = df$venue.location.lng)
coordinates$category <- df$category
coordinates <- coordinates %>%
  select(id, lat, lon, category) %>%
  group_by(id) %>%
  mutate(n = n())
