setwd("~/Development/wanderdata-scripts/spotify")

require(skimr)
require(parsedate)
require(lubridate)
require(ggplot2)
require(dplyr)
require(bbplot)
require(sugrrants)
require(tsibble)
require(viridis)
require(lubridate)
require(tidyr)

df <- read.csv("~/Development/wanderdata-scripts/spotify/df.csv", stringsAsFactors=FALSE)

plots_dir <- 'plots/'

df$posixct <-parse_date(df$PlayedAt)
df$date <- date(df$posixct)
df$weekday <- weekdays(df$posixct)
df$monthAndYear <- format(df$posixct, "%Y-%m")
df$hour <- hour(df$posixct)
df$minute <- minute(df$posixct)
df$second <- second(df$posixct)

df <- arrange(df, PlayedAt)

first.date <- head(df, n=1)$date
last.date <- tail(df, n=1)$date

# songs per day
songs.by.day <- df %>%
  group_by(date) %>%
  summarise(n = n()) 

p <- ggplot() +
  geom_line(data=songs.by.day, aes(x=date, y=n), linetype=1, color='#6d7d03') +
  geom_point(data=songs.by.day ,aes(x=date,y=n)) +
  scale_x_date(date_labels = '%Y-%m-%d', date_breaks='1 day') +
  labs(title="Number of songs I played on Spotify",
       subtitle = sprintf("From %s until %s", first.date, last.date)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  bbc_style() +
  xlab('Date') + ylab('Value') +
  theme(plot.margin = unit(c(1.0,1.5,1.0,1.0), 'cm')) 

ggsave(sprintf("%s%s_%s_%s.png", plots_dir,'played_songs', first.date, last.date), plot = p, 
       width = 12, height = 6.82, units = 'in')


# top artists
top.artists <- df %>%
  group_by(MainArtistName) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  mutate(percentage=(n/nrow(df)) * 100)

print(top.artists)

# top songs
top.songs <- df %>%
  group_by(Name) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  mutate(percentage=(n/nrow(df)) * 100)

print(top.songs)
