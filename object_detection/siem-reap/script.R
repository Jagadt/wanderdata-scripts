setwd("~/Development/wanderdata-scripts/object_detection/siem-reap")
require(jsonlite)
require(reshape2)
require(dplyr)
require(ggplot2)
require(bbplot)

df <- data.frame(object = factor(), count = numeric())
colnames(df) <- c('count', 'object')

data_dir <- 'data/'
for (f in list.files(data_dir)) { 
  tmp <- fromJSON(paste0(data_dir,'/', f))
  tmp <- melt(tmp)
  colnames(tmp) <- c('count', 'object')
  df <- rbind(tmp)
}

df <- df %>% 
  select(object, count) %>%
  group_by(object) %>%
  summarise(n = sum(count)) %>%
  mutate(percentage = (n/sum(n))) %>%
  arrange(desc(n))

print(sum(df$n))
print(df)
      

p <- ggplot(df[1:10,], aes(x=reorder(object, -percentage), y=percentage)) +
  geom_bar(stat = "identity") +
  labs(title="Top detected objects (in percentage)",
       subtitle = "From a sample of videos taken in Siem Reap, Cambodia") +
  xlab('Object') + ylab('Percentage') +
  bbc_style() +
  theme(axis.title = element_text(size = 24), 
        plot.margin = unit(c(1.0,1.5,1.0,1.0), 'cm'),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0))) +
  scale_y_continuous(labels=scales::percent) 
print(p)

p <- ggplot(tail(df, 15), aes(x=reorder(object, percentage), y=percentage)) +
  geom_bar(stat = "identity") +
  labs(title="Least common detected objects (in percentage)",
       subtitle = "From a sample of videos taken in Siem Reap, Cambodia") +
  xlab('Object') + ylab('Percentage') +
  bbc_style() +
  theme(axis.title = element_text(size = 24), 
        plot.margin = unit(c(1.0,1.5,1.0,1.0), 'cm'),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0))) +
  scale_y_continuous(labels=scales::percent) 
print(p)

write.table(df, file = 'df.csv', row.names = FALSE)
