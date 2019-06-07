setwd("~/Development/wanderdata-scripts/fitbit")

require(ggplot2)
require(bbplot)
require(skimr)

data_dir <- 'data/'
plots_dir <- 'plots/'

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
    activity.df$level <- f
    df <- rbind(df, activity.df)
  }
  
  df$dateTime <- as.Date(df$dateTime)
  first_date <- head(df, n=1)$dateTime
  last_date <- tail(df, n=1)$dateTime
  
  p <- ggplot(df, aes(x=level, y=value, fill=level)) + 
    geom_boxplot() +
    theme(plot.margin = unit(c(1.0,1.0,1.0,0.5), "cm"), 
          plot.title = element_text(family = 'Helvetica', size = 28, face = "bold", color = "#222222"),
          plot.subtitle = element_text(family = 'Helvetica', size = 22, margin = ggplot2::margin(9, 0, 9, 0)),
          axis.text = element_text(family = 'Helvetica', size = 18, color = "#222222"),
          axis.title.x = element_text(family = 'Helvetica', size = 14, color = "#222222"),
          axis.title.y = element_text(family = 'Helvetica', size = 14, color = "#222222")) +
    labs(title="My Fitbit's activity values boxplot",
         subtitle = sprintf("From %s until %s", first_date, last_date)) +
    xlab("Level") + ylab("Minutes")
  
  ggsave(sprintf("%s%s_%s_%s.png", plots_dir,'activity_levels_boxplot', first_date, last_date), plot = p, 
         width = 14, height = 8, units = 'in')
  
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
  
  ggsave(sprintf("%s%s_%s_%s.png", plots_dir,'activity_levels_values', first_date, last_date), plot = p, 
         width = 12, height = 6.82, units = 'in')
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
    first_date <- head(df, n=1)$dateTime
    last_date <- tail(df, n=1)$dateTime
    df$dateTime <- as.Date(df$dateTime)
    
    print(skim(df))
    
    p <- ggplot(df, aes(x="", y=value)) + 
      geom_boxplot(fill="#6d7d03") +
      theme(plot.margin = unit(c(1.0,1.0,1.0,0.5), "cm"), 
            plot.title = element_text(family = 'Helvetica', size = 28, face = "bold", color = "#222222"),
            plot.subtitle = element_text(family = 'Helvetica', size = 22, margin = ggplot2::margin(9, 0, 9, 0)),
            axis.text = element_text(family = 'Helvetica', size = 18, color = "#222222"),
            axis.title.x = element_text(family = 'Helvetica', size = 14, color = "#222222"),
            axis.title.y = element_text(family = 'Helvetica', size = 14, color = "#222222")) +
      labs(title=sprintf("\"%s\"%s boxplot", activity.name, unit),
           subtitle = sprintf("From %s until %s", first_date, last_date)) +
      xlab("") + ylab("Minutes")
    
    ggsave(sprintf("%s%s_%s_%s_%s.png", plots_dir, activity.name, 'boxplot', first_date, last_date), plot = p,
           width = 12, height = 6.82, units = 'in')


    
    
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
    
    ggsave(sprintf("%s%s_%s_%s_%s.png", plots_dir, activity.name, 'plot', first_date, last_date), plot = p, 
           width = 12, height = 6.82, units = 'in')
  }
}

create_activity_level_plots()
create_activity_plots()