#' Generate Irish grid references from an sf object
#'
#' `st_irishgridrefs()` returns the Irish grid references for point geometries
#' in an sf object that are located within the Irish Grid (EPSG:29903), and NA
#' otherwise.
#'
#' @inheritParams ig_to_igr
#' @param x an sf object containing geometries of type POINT.
#'
#' @return a character vector of Irish grid references.
#' @export
#'
#' @examples
#' # An sf object containing point data
#' x_sf <- sf::st_as_sf(data.frame(x = c(0, 490000), y = c(400000, 0)),
#'   crs = 29903,
#'   coords = c("x", "y")
#' )
#'
#' # Convert to Irish grid references
#' st_irishgridrefs(x_sf)
#'
#' # Convert to Irish grid references at 100 km precision
#' st_irishgridrefs(x_sf, digits = 0)
#'
#' # Convert to Irish grid references at 1 m precision
#' st_irishgridrefs(x_sf, digits = 5)
#'
#' # Insert a space between the 100 km grid letter, easting, and northing
#' st_irishgridrefs(x_sf, sep = " ")
st_irishgridrefs <- function(x, digits = 3, sep = "") {
  if (!inherits(x, "sf")) {
    stop_custom("not_sf", "x must be an sf object")
  }
  if (sf::st_geometry_type(x, by_geometry = FALSE) != "POINT") {
    stop_custom("not_sf_POINT", "x must contain geometry type POINT")
  }

  res <- x |>
    sf::st_transform(crs = 29903) |>
    sf::st_coordinates() |>
    ig_to_igr(digits = digits, sep = sep)

  return(res)
}
