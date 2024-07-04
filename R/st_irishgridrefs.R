#' Generate Irish Grid References from sf point data
#'
#' @param x an sf object containing point data within the Irish Grid bounding box.
#' @param digits resolution of grid references to generate, between 0 (100km) and 5 (1m).
#' @param sep a character to separate the 100km grid letter, easting, and northing.
#'
#' @return a character vector of Irish Grid References.
#' @export
#'
#' @examples
#' x_sf <- sf::st_as_sf(data.frame(x = c(0, 490000), y = c(400000, 0)),
#'   crs = 29903,
#'   coords = c("x", "y")
#' )
#' st_irishgridrefs(x_sf)
#' st_irishgridrefs(x_sf, digits = 0)
#' st_irishgridrefs(x_sf, digits = 5)
st_irishgridrefs <- function(x, digits = 3, sep = "") {
  res <- x |>
    sf::st_transform(crs = 29903) |>
    sf::st_coordinates() |>
    ig_to_igr(digits = digits, sep = sep)

  return(res)
}
