setwd("~/Development/wanderdata-scripts/fitbit")

require(ggplot2)
require(bbplot)
require(skimr)
require(parsedate)
require(reshape2)
require(lubridate)

data_dir <- 'data/'
plots_dir <- 'plots/'

args = commandArgs(trailingOnly=TRUE)
args <- c('2019-06-16', '2019-06-28')

if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else {
  # starting day
  print(args[1])
  print(args[2])
}

# this function produces the plots of the different activity levels
create_activity_level_plots <- function(variables) {
  # activity level per minutes plots
  df <- data.frame(dateTime=character(),
                                  value=numeric(), 
                                  level=character(), 
                                  stringsAsFactors=FALSE) 
  
  # read only these files
  for (f in c('minutesSedentary', 'minutesLightlyActive','minutesFairlyActive', 'minutesVeryActive')) {
    print(f)
    activity.df <- read.csv(sprintf("~/Development/wanderdata-scripts/fitbit/data/%s.csv", f))
    print(skim(activity.df))
    print(sum(activity.df$value))
    activity.df$level <- f
    df <- rbind(df, activity.df)
  }

  
  df$dateTime <- as.Date(df$dateTime)
  df <- df[df$dateTime >= args[1] & df$dateTime < args[2],]
  first_date <- head(df, n=1)$dateTime
  last_date <- tail(df, n=1)$dateTime
  
  p <- ggplot(df, aes(x=level, y=value, fill=level)) + 
    geom_boxplot() +
    theme(plot.margin = unit(c(1.0,1.0,1.0,0.5), "cm"), 
          plot.title = element_text(family = 'Helvetica', size = 28, face = "bold", color = "#222222"),
          plot.subtitle = element_text(family = 'Helvetica', size = 22, margin = ggplot2::margin(9, 0, 9, 0)),
          axis.text = element_text(family = 'Helvetica', size = 18, color = "#222222"),
          axis.title.x = element_text(family = 'Helvetica', size = 18, color = "#222222"),
          axis.title.y = element_text(family = 'Helvetica', size = 18, color = "#222222"),
          legend.text=element_text(size=14),
          legend.position = "top", legend.text.align = 0, legend.background = ggplot2::element_blank(),
          legend.title = ggplot2::element_blank(), legend.key = ggplot2::element_blank()) +
    labs(title="My Fitbit's activity values boxplot",
         subtitle = sprintf("From %s until %s", first_date, last_date)) +
    xlab("Level") + ylab("Minutes")
  
  ggsave(sprintf("%s%s_%s_%s.jpg", plots_dir,'activity_levels_boxplot', first_date, last_date), plot = p, 
         width = 13, height = 7, units = 'in')
  
  p <- ggplot() +
    geom_line(data=subset(df,dateTime<=as.character(first_date)),aes(x=dateTime,y=value, color=level),
              linetype=2) +
    geom_point(data=subset(df,dateTime<=as.character(first_date)),aes(x=dateTime,y=value)) +
    geom_line(data=subset(df,dateTime>=as.character(first_date)),aes(x=dateTime,y=value, color=level),
              linetype=1) +
    geom_point(data=subset(df,dateTime>=as.character(first_date)),aes(x=dateTime,y=value)) +
    scale_x_date(date_labels = "%Y-%m-%d", date_breaks="1 day") +
    labs(title="Minutes at activity level according to my Fitbit",
         subtitle = sprintf("From %s until %s", first_date, last_date)) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    bbc_style() +
    xlab('Date') + ylab('Value') +
    theme(plot.margin = unit(c(1.0,1.5,1.0,0.5), "cm")) 
  
  ggsave(sprintf("%s%s_%s_%s.jpg", plots_dir,'activity_levels_values', first_date, last_date), plot = p, 
         width = 11, height = 5, units = 'in')
}

# this function produces the plots of the different activities
create_activity_plots <- function() {
  # produce activity plots
  for (f in list.files(data_dir)) {
    unit <- ""
    unit.label <- ""
    activity.name <- gsub("\\..*","",f)
    
    # ignore the files that are related to activity level per minutes
    if (grepl('minutes',f)) {
      next
    }

    if (activity.name == 'elevation') {
      unit <- ' (m)'
    } else if (activity.name == 'distance') {
      unit <- ' (km)'
    } else {
      next
    }
    
    print(f)
    
    df <- read.csv(sprintf("%s/%s", data_dir, f))
    df$dateTime <- as.Date(df$dateTime)
    df <- df[df$dateTime >= args[1] & df$dateTime < args[2],]
    first_date <- head(df, n=1)$dateTime
    last_date <- tail(df, n=1)$dateTime
    
    print(skim(df))
    
    p <- ggplot() +
      geom_line(data=subset(df,dateTime<=as.character(first_date)),aes(x=dateTime,y=value),
                linetype=2, color='#6d7d03') +
      geom_point(data=subset(df,dateTime<=as.character(first_date)),aes(x=dateTime,y=value)) +
      geom_line(data=subset(df,dateTime>=as.character(first_date)),aes(x=dateTime,y=value),
                linetype=1, color='#6d7d03') +
      geom_point(data=subset(df,dateTime>=as.character(first_date)),aes(x=dateTime,y=value)) +
      scale_x_date(date_labels = "%Y-%m-%d", date_breaks="1 day") +
      labs(title=sprintf("My Fitbit's \"%s\"%s values", activity.name, unit),
           subtitle = sprintf("From %s until %s", first_date, last_date)) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      xlab('Date') + ylab('Value') +
      theme(plot.margin = unit(c(1.0,1.0,1.0,0.5), "cm")) +
      bbc_style()
    
    ggsave(sprintf("%s%s_%s_%s_%s.jpg", plots_dir, activity.name, 'plot', first_date, last_date), plot = p, 
           width = 10, height = 5, units = 'in')
  }
}

create_distance_steps_plots <- function() {
  print("create_distance_steps_plots")
  # produce activity plots
  distance.df <- read.csv("~/Development/wanderdata-scripts/fitbit/data/distance.csv")
  steps.df <- read.csv("~/Development/wanderdata-scripts/fitbit/data/steps.csv")
  print("Steps")
  print(skim(steps.df))
  distance.df$metric <- "distance"
  steps.df$metric <- "steps"

  df <- rbind(distance.df, steps.df)
  df$dateTime <- as.Date(df$dateTime)
  df <- df[df$dateTime >= args[1] & df$dateTime < args[2],]
  first_date <- head(df, n=1)$dateTime
  last_date <- tail(df, n=1)$dateTime
  print(cor(distance.df$value, steps.df$value))
  
  p <- ggplot() +
    geom_line(data=subset(df,dateTime<=as.character(first_date)),aes(x=dateTime,y=value, color = metric)) +
    geom_point(data=subset(df,dateTime<=as.character(first_date)),aes(x=dateTime,y=value)) +
    geom_line(data=subset(df,dateTime>=as.character(first_date)),aes(x=dateTime,y=value, color = metric)) +
    geom_point(data=subset(df,dateTime>=as.character(first_date)),aes(x=dateTime,y=value)) +
    scale_y_continuous(sec.axis= sec_axis(~.*1, name="Steps"), trans = "log10") +
    scale_x_date(date_labels = "%Y-%m-%d", date_breaks="1 day") +
    bbc_style() +
    theme(axis.title = element_text(size = 18), 
          plot.margin = unit(c(1.0,1.0,1.0,0.5), "cm"),
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title="My Fitbit's distance (km) and steps values (in log scale)",
         subtitle = sprintf("From %s until %s", first_date, last_date)) +
    ylab("Distance") +
    xlab("Value")

  
  ggsave(sprintf("%s%s_%s_%s.jpg", plots_dir, "distance_steps_plot", first_date, last_date), plot = p, 
          width = 12, height = 6, units = 'in')

}

create_sleep_plots <- function() {
  print("create_sleep_plots")
  # produce activity plots
  df <- read.csv("~/Development/wanderdata-scripts/fitbit/data/sleep.csv", stringsAsFactors = FALSE)
  df$date <- date(df$date)
  df <- df[df$date >= args[1] & df$date < args[2],]
  
  df$start.time.posixct <-as.POSIXct(df$startTime, format="%Y-%m-%dT%H:%M:%OS")
  df$end.time.posixct <-as.POSIXct(df$endTime, format="%Y-%m-%dT%H:%M:%OS")
  
  
  df$decimal.start <- hour(df$start.time.posixct) + minute(df$start.time.posixct)/60
  df$decimal.end <- hour(df$end.time.posixct) + minute(df$end.time.posixct)/60
  
  print(skim(df))
  
  first_date <- head(df, n=1)$date
  last_date <- tail(df, n=1)$date
  
  df.times <- data.frame(dateTime = df$date, startTime = df$decimal.start, endTime = df$decimal.end)
  
  df.times <- melt(df.times, id.vars = c("dateTime"))
  
  p <- ggplot() +
    geom_line(data=df.times, aes(x = dateTime, y = value, color = variable)) +
    geom_point(data=df.times ,aes(x=dateTime,y=value)) +
    bbc_style() +
    scale_x_date(date_labels = "%Y-%m-%d", date_breaks="1 day") +
    scale_y_continuous(breaks = round(seq(min(df.times$value), max(df.times$value), by = 2))) +
    theme(axis.title = element_text(size = 18), 
          plot.margin = unit(c(1.0,1.0,1.0,0.5), "cm"),
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title="My sleeping times (start and end) according to Fitbit",
         subtitle = sprintf("From %s until %s", first_date, last_date)) +
    ylab("Hour") +
    xlab("Date")
  
  ggsave(sprintf("%s%s_%s_%s.jpg", plots_dir, "sleep_start_end_times", first_date, last_date), plot = p, 
         width = 12, height = 6, units = 'in')
  
  p <- ggplot() +
    geom_line(data=df, aes(x=date,y=minutesAsleep), color = "#6d7d03") +
    geom_point(data=df ,aes(x=date,y=minutesAsleep)) +
    bbc_style() +
    scale_x_date(date_labels = "%Y-%m-%d", date_breaks="1 day") +
    theme(axis.title = element_text(size = 18), 
          plot.margin = unit(c(1.0,1.0,1.0,0.5), "cm"),
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title="My minutes asleep according to Fitbit",
         subtitle = sprintf("From %s until %s", first_date, last_date)) +
    ylab("Minutes") +
    xlab("Date")
  
  ggsave(sprintf("%s%s_%s_%s.jpg", plots_dir, "sleepy_minutes", first_date, last_date), plot = p, 
         width = 12, height = 6, units = 'in')
  
  
  p <- ggplot(df, aes(x=date, y=minutesAsleep)) + 
    geom_boxplot(aes(group=1), fill = "#6d7d03") +
    theme(plot.margin = unit(c(1.0,1.0,1.0,0.5), "cm"), 
          plot.title = element_text(family = 'Helvetica', size = 28, face = "bold", color = "#222222"),
          plot.subtitle = element_text(family = 'Helvetica', size = 22, margin = ggplot2::margin(9, 0, 9, 0)),
          axis.text = element_text(family = 'Helvetica', size = 18, color = "#222222"),
          axis.title.x = element_text(family = 'Helvetica', size = 18, color = "#222222"),
          axis.title.y = element_text(family = 'Helvetica', size = 18, color = "#222222"),
          legend.text=element_text(size=14),
          legend.position = "top", legend.text.align = 0, legend.background = ggplot2::element_blank(),
          legend.title = ggplot2::element_blank(), legend.key = ggplot2::element_blank()) +
    labs(title="My minutes asleep boxplot",
         subtitle = sprintf("From %s until %s", first_date, last_date)) +
    ylab("Minutes") +
    xlab("Date")
  
  ggsave(sprintf("%s%s_%s_%s.jpg", plots_dir,'sleepy_minutes_boxplot', first_date, last_date), plot = p, 
         width = 13, height = 7, units = 'in')
  
}

create_activity_level_plots()
create_activity_plots()
create_distance_steps_plots()
create_sleep_plots()
