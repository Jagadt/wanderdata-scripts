require(ggplot2)
require(bbplot)
require(skimr)
require(parsedate)
require(reshape2)
require(lubridate)

df <- read.csv("~/Development/wanderdata-scripts/fitbit/data/steps.csv", stringsAsFactors = FALSE)
df <- df[df$dateTime >= '2019-07-09' & df$dateTime < '2019-08-02',]

df$dateTime <- as.Date(df$dateTime)

print(skim(df))

p <- ggplot(df, aes(x=dateTime, y=value)) +
  geom_line() +
  geom_point() +
  scale_x_date(date_labels = "%Y-%m-%d", date_breaks="1 day") +
  labs(title="title",
       subtitle = "subtitle") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  xlab('Date') + ylab('Value') +
  theme(plot.margin = unit(c(1.0,1.0,1.0,0.5), "cm")) +
  bbc_style()

p


ggsave(sprintf("%s%s_%s_%s_%s.jpg", plots_dir, activity.name, 'plot', first_date, last_date), plot = p, 
       width = 10, height = 5, units = 'in')
