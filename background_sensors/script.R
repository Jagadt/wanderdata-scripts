args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else {
  # starting day
  print(args[1])
  print(args[2])
  print(args[3])
}

setwd("~/Development/wanderdata-scripts/background_sensors")

require(lubridate)
require(parsedate)
require(scales)
require(dplyr)
require(ggplot2)
require(bbplot)
require(skimr)

data_dir <- 'data/'
plots_dir <- 'plots/'

sensors_plots <- function(variables) {
  print("Sensors plots")
  for (f in list.files(data_dir)) {
    unit <- ''
    unit.label <- ''
    
    sensor.name <- gsub("_.*","",f)
    print(f)
    df <- read.csv(sprintf("%s/%s", data_dir, f), header = FALSE, stringsAsFactors = FALSE)
    colnames(df) <- c('ts', 'value')
    
    
    df$posixct <- parsedate::parse_date(df$ts)
    df$date <- date(df$posixct)
    df$hour <- hour(df$posixct)
    present.date <- args[2]
    last.date <- args[3]
    df <- df[df$date >= args[1] & df$date < args[3],]

    print(present.date)
    print(last.date)
    
    first.date <- head(df, n=1)$date
    last.date.label <- tail(df, n=1)$date
    
    summarized.values <- df %>%
      select(posixct, value, date, hour) %>%
      group_by(date, hour) %>%
      mutate(n = median(value))
    
    if (sensor.name == 'barometer') {
      unit <- 'hPa'
      unit.label <- 'Atmospheric pressure'
    } else if (sensor.name == 'lightmeter') {
      unit <- 'lx'
      unit.label <- 'Light intensity'
    } else {
      next
    }
    
    
    print(skim(as.data.frame(summarized.values)))
    
    p <- ggplot() +
          # geom_smooth(data=subset(summarized.values, posixct <= present.date), aes(x = posixct, y = n), linetype = 2, method = "lm", span = 1.0, color = '#6d7d03') +
          geom_point(data=subset(summarized.values, posixct > present.date && posixct < last.date) ,aes(x = posixct,y=n), alpha = 0.3) +
          geom_smooth(data=subset(summarized.values, posixct > present.date && posixct < last.date), aes(x = posixct, y = n), linetype = 1, method = "loess", span = 0.05, color = '#6d7d03') +
          scale_x_datetime(date_breaks="1 day") +
          labs(title=sprintf("%s value (%s) according to my phone", unit.label, unit),
               subtitle = sprintf("From %s until %s", first.date, args[3])) +
          xlab('Date') + ylab(unit) +
          bbc_style() +
          theme(plot.margin = unit(c(1.0,1.5,1.0,0.5), "cm")) +
          theme(axis.text.x = element_text(angle = 90))
    
    ggsave(sprintf("%s%s_%s_%s.jpg", plots_dir, sensor.name , first.date, last.date), plot = p, 
           width = 12, height = 6.82, units = 'in')
    
  }
  
}

daily_lx_plot <- function() {
  print("Daily lx plot")
  df <- read.csv(sprintf("%s/lightmeter_background.csv", data_dir), header = FALSE, stringsAsFactors = FALSE)
  colnames(df) <- c('ts', 'value')
  
  df$posixct <- parsedate::parse_date(df$ts)
  df$date <- date(df$posixct)
  df$hour <- hour(df$posixct)
  df <- df[df$date >= args[1] & df$date < args[3],]
  
  first.date <- head(df, n=1)$date
  last.date <- tail(df, n=1)$date
  
  median.hourly.value <- df %>%
    select(value, hour) %>%
    group_by(hour) %>%
    mutate(n = mean(value))
  
  print(skim(df))
  
  p <- ggplot() +
    geom_line(data=median.hourly.value, aes(x=hour, y=n), linetype=1, color='#6d7d03') +
    geom_point(data=median.hourly.value ,aes(x=hour,y=n), alpha=0.3) +
    labs(title="Average light intensity (lx) value by hour according to my phone",
         subtitle = sprintf("From %s until %s", first.date, args[3])) +
    bbc_style() +
    xlab('Date') + ylab(unit) +
    theme(plot.margin = unit(c(1.0,1.5,1.0,0.5), "cm")) 
  
  ggsave(sprintf("%s%s_%s_%s.jpg", plots_dir, "median_lx" , first.date, args[3]), plot = p, 
         width = 14, height = 6.82, units = 'in')
}

lx_weather_cloudiness <- function() {
  print("Daily lx plot")
  df <- read.csv(sprintf("%s/lightmeter_background.csv", data_dir), header = FALSE, stringsAsFactors = FALSE)
  colnames(df) <- c('ts', 'value')
  
  df$posixct <- parsedate::parse_date(df$ts)
  df$date <- date(df$posixct)
  df$hour <- hour(df$posixct)
  df <- df[df$date >= args[1] & df$date < args[3],]
  
  first.date <- head(df, n=1)$date
  last.date <- tail(df, n=1)$date
  
  weather.df <- read.csv("../weather/df.csv", stringsAsFactors = FALSE)
  weather.df$posixct <- parsedate::parse_date(weather.df$dt)
  weather.df$date <- date(weather.df$posixct)
  weather.df$hour <- hour(weather.df$posixct)
  
  values.df <- data.frame(hour=numeric(),
                          value=numeric(), 
                          level=character(), 
                          stringsAsFactors=FALSE) 
  
  median.daily.value <- df %>%
    select(value, date) %>%
    group_by(date) %>%
    summarize(n = median(value))
  median.daily.value$level <- 'lx'
  median.daily.value$lx <- NULL
  median.daily.value$value <- NULL
  values.df <- rbind(values.df, median.daily.value)
  
  cloudiness.median.hourly.value <- weather.df %>%
    select(cloudiness, date) %>%
    group_by(date) %>%
    summarize(n = median(cloudiness))
  cloudiness.median.hourly.value$level <- 'cloudiness'
  cloudiness.median.hourly.value$cloudiness <- NULL
  values.df <- rbind(values.df, cloudiness.median.hourly.value)
  
  
  colnames(values.df) <- c('daydate', 'n', 'level' )
  
  p <- ggplot() +
    geom_line(data=values.df, aes(x=daydate, y=n, color=level), linetype=1) +
    geom_point(data=values.df ,aes(x=daydate,y=n), alpha=0.3) +
    scale_y_continuous(sec.axis= sec_axis(~.*1, name="lx"), trans = "log10") +
    labs(title="Daily median light intensity (lx) and cloudiness values",
         subtitle = sprintf("From %s until %s", first.date, args[3])) +
    bbc_style() +
    xlab('Hour') + ylab('Value') +
    theme(plot.margin = unit(c(1.0,1.5,1.0,0.5), "cm"),
          axis.title = element_text(size = 18),
          axis.text.x = element_text(angle = 90)) +
    scale_x_date(breaks = values.df$daydate) 
  
  ggsave(sprintf("%s%s_%s_%s.jpg", plots_dir, "lx_cloudiness" , first.date, args[3]), plot = p, 
         width = 14, height = 6.82, units = 'in')
}

sensors_plots()
daily_lx_plot()
lx_weather_cloudiness()
