library(OpenStreetMap)

df <- fromJSON('~/Development/wanderdata-scripts/swarmapp/data/checkins.json')

# json to dataframe
df <- flatten(df)

# create a new category column by select the category from the nested structure 'venue.category'
df$category <- sapply(df$venue.categories, function(x) x$name)
df$posixct <- parsedate::parse_date(df$createdAt)
df$date <- date(df$posixct)
df$hour <- hour(df$posixct)


df <- df[df$venue.location.cc == 'SG',]

coordinates <- data.frame(id = df$venue.id, lat = df$venue.location.lat, lon = df$venue.location.lng)
coordinates$category <- df$category


# c(up, left), c(down,right)
singapore.map <- openmap(c(1.4885,103.6059),
               c(1.1899,104.0625),
               minNumTiles=40)

map_longlat <- openproj(singapore.map)

autoplot(map_longlat) +
  geom_point(data = coordinates, 
             aes(x = coordinates$lon, y = coordinates$lat)) +
  stat_density2d(data=coordinates, aes(x=coordinates$lon, y=coordinates$lat, fill=..level.., alpha=..level..),
                 geom='polygon', size=0.01, bins=5) +
  scale_color_brewer(palette='Set1')+
  theme(legend.position = 'none',
        plot.title = element_text(size = 22),
        plot.subtitle = element_text(size = 18),
        axis.text.x  = element_text(size = 14),
        axis.text.y  = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        plot.margin = unit(c(1.0,1.5,1.0,0.5), 'cm')) +
  xlab('Longitude') + ylab('Latitude') +
  ggtitle('My Swarm check-ins', subtitle = 'From July 4, 2019 until July 10, 2019')