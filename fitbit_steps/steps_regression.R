distance.df <- read.csv("~/Development/wanderdata-scripts/fitbit/data/distance.csv")
steps.df <- read.csv("~/Development/wanderdata-scripts/fitbit/data/steps.csv")
ds.df <- merge(distance.df, steps.df, by = 'dateTime')
ds.df$dateTime <- NULL
colnames(ds.df) <- c('distance', 'steps')
lm.model <- lm(steps ~ ., data = ds.df)
plot(lm.model)
summary(lm.model)


plot(ds.df$steps, ds.df$distance)