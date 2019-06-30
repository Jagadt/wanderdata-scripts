setwd("~/Development/wanderdata-scripts/unsupervised-city-planning/singapore")

require(cluster)
require(geosphere)
require(maptools)
require(ggplot2)
require(NbClust)
require(factoextra)
devtools::install_github("dkahle/ggmap")
require(ggmap)

# modified version of usedist's package dist_make() function
# this function creates a dissimilarity matrix using haversine distance as dissimilarity metric
my_dist_make <- function (x, method = NULL) 
{
  distance_from_idxs <- function(idxs) {
    i1 <- idxs[1]
    i2 <- idxs[2]
    distHaversine(x[i1, ], x[i2, ], r = 6371)
  }
  size <- nrow(x)
  d <- apply(utils::combn(size, 2), 2, distance_from_idxs)
  attr(d, "Size") <- size
  xnames <- rownames(x)
  if (!is.null(xnames)) {
    attr(d, "Labels") <- xnames
  }
  attr(d, "Diag") <- FALSE
  attr(d, "Upper") <- FALSE
  if (!is.null(method)) {
    attr(d, "method") <- method
  }
  class(d) <- "dist"
  d
}


# data pre-processing
raw.coordinates <- getKMLcoordinates('data.xml')
# INFO: X1 is longitude and X2 is latitude
coordinates <- data.frame(matrix(unlist(raw.coordinates), nrow=length(raw.coordinates), byrow=T))
coordinates$X3 <- NULL
# compute the dissimilarity matrix
distances <- my_dist_make(coordinates, distHaversine)

ggplot(coordinates, aes(x = X1, y = X2)) +
  geom_point() +
  theme(legend.position = 'none',
        plot.title = element_text(size = 22),
        plot.subtitle = element_text(size = 18),
        axis.text.x  = element_text(size = 14),
        axis.text.y  = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        plot.margin = unit(c(1.0,1.5,1.0,0.5), "cm")) +
  xlab("Longitude") + ylab("Latitude") +
  ggtitle("Coordinates scatterplot")
  

# diss is TRUE because we are using a dissimilarity matrix as input
p <- pam(distances, k = 4, diss = TRUE)
coordinates$cluster <- as.factor(p$clustering)

# general map
center=c(103.8303, 1.249404)
map <- get_googlemap("singapore", zoom = 11, maptype = 'roadmap', size = c(640, 640), scale = 2) 
map %>% ggmap() +
  geom_point(data = coordinates, 
             aes(x = coordinates$X1, y = coordinates$X2, color = coordinates$cluster, size = 12, alpha = 0.95)) +
  scale_color_brewer(palette="Set1")+
  theme(legend.position = 'none',
        plot.title = element_text(size = 22),
        plot.subtitle = element_text(size = 18),
        axis.text.x  = element_text(size = 14),
        axis.text.y  = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14)) +
  xlab("Longtitude") + ylab("Latitude") +
  ggtitle("Singapore Plan Clusters", subtitle = 'Where each cluster (color) represents one day')
  
map.sentosa <- get_googlemap(center=c(103.81749, 1.27378) , zoom = 13, maptype = 'roadmap', size = c(640, 640), scale = 2) 
map.sentosa %>% ggmap() +
  geom_point(data = coordinates[coordinates$cluster == 1,], 
             aes(x = X1, y = X2, size = 12)) +
  scale_color_brewer(palette="Set1")+
  theme(legend.position = 'none',
        plot.title = element_text(size = 22),
        plot.subtitle = element_text(size = 18),
        axis.text.x  = element_text(size = 14),
        axis.text.y  = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14)) +
  xlab("Longtitude") + ylab("Latitude") +
  ggtitle("Singapore Plan Clusters  #1", subtitle = 'Sentosa Island Area')

map.downtown <- get_googlemap(center=c(103.85921, 1.30184) , zoom = 13, maptype = 'roadmap', size = c(640, 640), scale = 2) 
map.downtown %>% ggmap() +
  geom_point(data = coordinates[coordinates$cluster == 2,], 
             aes(x = X1, y = X2, size = 12)) +
  scale_color_brewer(palette="Set1")+
  theme(legend.position = 'none',
        plot.title = element_text(size = 22),
        plot.subtitle = element_text(size = 18),
        axis.text.x  = element_text(size = 14),
        axis.text.y  = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14)) +
  xlab("Longtitude") + ylab("Latitude") +
  ggtitle("Singapore Plan Clusters  #2", subtitle = 'Downtown Area')

map.natural.reserve <- get_googlemap(center=c(103.81252, 1.36072) , zoom = 13, maptype = 'roadmap', size = c(640, 640), scale = 2) 
map.natural.reserve %>% ggmap() +
  geom_point(data = coordinates[coordinates$cluster == 4,], 
             aes(x = X1, y = X2, size = 12)) +
  scale_color_brewer(palette="Set1")+
  theme(legend.position = 'none',
        plot.title = element_text(size = 22),
        plot.subtitle = element_text(size = 18),
        axis.text.x  = element_text(size = 14),
        axis.text.y  = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14)) +
  xlab("Longtitude") + ylab("Latitude") +
  ggtitle("Singapore Plan Clusters  #1", subtitle = 'Natural Reserve Area')

map.airport <- get_googlemap(center='changi airport' , zoom = 15, maptype = 'roadmap', size = c(640, 640), scale = 2) 
map.airport %>% ggmap() +
  geom_point(data = coordinates[coordinates$cluster == 3,], 
             aes(x = X1, y = X2, size = 12)) +
  scale_color_brewer(palette='Set1')+
  theme(legend.position = 'none',
        plot.title = element_text(size = 22),
        plot.subtitle = element_text(size = 18),
        axis.text.x  = element_text(size = 14),
        axis.text.y  = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14)) +
  xlab('Longtitude') + ylab('Latitude') +
  ggtitle("Singapore Plan Cluster  #3", subtitle = "Changi Airport Area")


# clustering information
print(p$clusinfo)

