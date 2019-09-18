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

# remove everything that isn't Singapore
df <- df[df$venue.location.cc == 'SG',]

coordinates <- data.frame(id = df$venue.id, lat = df$venue.location.lat, lon = df$venue.location.lng, category = df$category)
coordinates <- coordinates %>%
  select(id, lat, lon, category) %>%
  group_by(id) %>%
  mutate(n = n())

map <- get_googlemap('singapore', zoom = 11, maptype = 'roadmap', size = c(640, 640), scale = 2) 

map %>% ggmap() +
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


map.downtown <- get_googlemap(center=c(103.85921, 1.30184) , zoom = 14, maptype = 'roadmap', size = c(640, 640), scale = 2) 

map.downtown %>% ggmap() +
  geom_point(data = coordinates, 
             aes(x = coordinates$lon, y = coordinates$lat, size=coordinates$n)) +
  stat_density2d(data=coordinates, aes(x=coordinates$lon, y=coordinates$lat, fill=..level.., alpha=..level..),
                 geom='polygon', size=0.01, bins=5) +
  scale_fill_viridis_c() +
  scale_size(range = c(3.0, 10.0)) +
  scale_alpha(range = c(0.1, 0.5)) +
  theme(legend.position = 'none',
        plot.title = element_text(size = 22),
        plot.subtitle = element_text(size = 18),
        axis.text.x  = element_text(size = 14),
        axis.text.y  = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14)) +
  xlab('Longitude') + ylab('Latitude') +
  ggtitle('My Swarm check-ins from the center of Singapore', subtitle = 'From July 4, 2019 until July 10, 2019')


top.categories <- df %>%
  select(category) %>%
  group_by(category) %>%
  summarise(n = n()) %>%
  arrange(n, desc(n))

ggplot(top.categories, aes(x=reorder(category, -n), y=n)) +
  geom_bar(stat = 'identity') +
  ggtitle("My check-ins categories")+
  bbc_style() +
  xlab("Category") +
  ylab("Check-ins") +
  theme(axis.title = element_text(size = 24), 
        plot.margin = unit(c(1.0,1.5,1.0,1.0), "cm"),
        axis.text.x = element_text(hjust = 1, angle = 90),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0))) 

top.categories.hour <- df %>%
  select(category, hour) %>%
  group_by(category) %>%
  mutate(n = n()) %>%
  arrange(n, desc(n))

ggplot(top.categories.hour[top.categories.hour$n > 1,], aes(factor(category), hour)) +
  geom_violin() +
  geom_point() +
  ggtitle("Check-ins times of my top categories") +
  bbc_style() +
  xlab("Category") +
  ylab("Hour") +
  theme(axis.title = element_text(size = 24), 
        plot.margin = unit(c(1.0,1.5,1.0,1.0), "cm"),
        axis.text.x = element_text(hjust = 1),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0))) 


