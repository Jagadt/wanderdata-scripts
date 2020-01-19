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

df <- read.csv("~/Development/wanderdata-scripts/spotify/data/df.csv", stringsAsFactors=FALSE)

plots_dir <- 'plots/'

df$posixct <-parsedate::parse_date(df$PlayedAt)
# IMPORTANT! Change the timezone!
df$posixct <- with_tz(df$posixct, "CET")
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
  summarise(n = n()) %>%
  complete(date = seq.Date(min(date), max(date), by="day"))
songs.by.day[is.na(songs.by.day)] <- 0


print(skim(songs.by.day))
print(sum(songs.by.day$n))

p <- ggplot() +
  geom_line(data=songs.by.day, aes(x=date, y=n), linetype=1, color='#6d7d03') +
  geom_point(data=songs.by.day ,aes(x=date,y=n)) +
  scale_x_date(date_labels = '%Y-%m-%d', date_breaks='1 week') +
  labs(title="Number of songs I played on Spotify",
       subtitle = sprintf("From %s until %s", first.date, last.date)) +
  bbc_style() +
  theme(axis.title = element_text(size = 18), 
        plot.margin = unit(c(1.0,1.5,1.0,1.0), "cm"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0))) +
  xlab('Date') + ylab('Value')

ggsave(sprintf("%s%s_%s_%s.jpg", plots_dir,'played_songs', first.date, last.date), plot = p, 
       width = 12, height = 6.82, units = 'in')


songs.by.hour <- df %>%
  select(hour) %>%
  group_by(hour) %>%
  summarise(n = n()) %>%
  complete(hour = 0:23)
songs.by.hour[is.na(songs.by.hour)] <- 0

p <- ggplot() +
  geom_line(data=songs.by.hour, aes(x=hour, y=n), linetype=1, color='#6d7d03') +
  geom_point(data=songs.by.hour ,aes(x=hour,y=n)) +
  labs(title="Number of songs I played on Spotify grouped by hour",
       subtitle = sprintf("From %s until %s", first.date, last.date)) +
  bbc_style() +
  theme(axis.title = element_text(size = 18), 
        plot.margin = unit(c(1.0, 1.5, 1.0,1.0), "cm"),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0))) +
  scale_x_continuous("hour", breaks = 0:23) +
  xlab('Hour') + ylab('Value')

ggsave(sprintf("%s%s_%s_%s.jpg", plots_dir,'played_songs_hours', first.date, last.date), plot = p, 
       width = 12, height = 6.82, units = 'in')


# top artists
top.artists <- df %>%
  group_by(MainArtistName) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  mutate(percentage=(n/nrow(df)) * 100)

print(head(top.artists))

# top songs
top.songs <- df %>%
  group_by(Name) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  mutate(percentage=(n/nrow(df)) * 100)

print(head(top.songs, n = 10))
