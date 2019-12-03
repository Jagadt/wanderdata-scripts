require(readr)

raw <- read_file('~/Development/wanderdata-scripts/unsupervised-city-planning/hongkong/data/raw.kml')

# both functions are taken from https://gist.github.com/briatte/18a4d543d1ccca194b2a03ac512be2b4
kml_points <- function(x, layer = "d1", verbose = TRUE) {
  
  require(dplyr)
  require(stringr)
  require(xml2)
  
  #' Extract Placemark fields.
  #' 
  #' @param x A nodeset of Placemarks.
  #' @param field The name of the field to extract, e.g. \code{"name"}.
  #' @param layer The name of the layer to extract from; defaults to \code{"d1"}.
  #' @return A character vector. Missing values, i.e. empty fields, will be
  #' returned as \code{NA} values.
  get_field <- function(x, field, layer = "d1") {
    
    # vectorization required to get missing values when field is xml_missing
    lapply(x, xml_find_first, str_c(layer, ":", field)) %>%
      sapply(xml_text)
    
  }
  
  x <- read_xml(x) %>%
    xml_find_all(str_c("//", layer, ":Point/.."))
  
  x <- data_frame(
    name = get_field(x, "name", layer),
    description = get_field(x, "description", layer),
    styleUrl = get_field(x, "styleUrl", layer),
    coordinates = get_field(x, str_c("Point/", layer, ":coordinates"), layer)
  )
  
  x$longitude <- kml_coordinate(x$coordinates, 1, verbose)
  x$latitude  <- kml_coordinate(x$coordinates, 2, verbose)
  x$altitude  <- kml_coordinate(x$coordinates, 3, verbose)
  
  return(select(x, -coordinates))
  
}

kml_coordinate <- function(x, coord, verbose = TRUE) {
  
  require(stringr) # includes `%>%`
  
  x <- str_replace(x, "(.*),(.*),(.*)", str_c("\\", coord)) %>%
    as.numeric
  
  if (verbose && coord == 1 && any(abs(x) > 180))
    message("Some longitudes are not contained within [-180, 180].")
  
  if (verbose && coord == 2 && any(abs(x) > 90))
    message("Some latitudes are not contained within [-90, 90].")
  
  if (verbose && coord == 3 && any(x < 0))
    message("Some altitudes are below sea level.")
  
  return(x)
  
}

df <- kml_points(raw)
head(df)
