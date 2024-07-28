#' Generate Irish grid references from an sf object
#'
#' `st_irishgridrefs()` returns the Irish grid references for all features in an
#' sf object of point geometries. Features located outside the Irish Grid
#' (EPSG:29903) extent are returned as NA.
#'
#' @inheritParams ig_to_igr
#' @param x An sf object containing geometries of type POINT.
#'
#' @return A character vector of Irish grid references.
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
#' # Convert into Irish grid references with 4 digit easting and northing (10 m precision)
#' st_irishgridrefs(x_sf, digits = 4)
#'
#' # Convert into Irish grid references with 1 km precision (2 digit easting and northing)
#' st_irishgridrefs(x_sf, precision = 1000)
#' 
#' # Convert into Irish grid references with 2 km precision (tetrad form)
#' st_irishgridrefs(x_sf, precision = 2000)
#'
#' # Insert a space between the 100 km grid letter, easting, and northing
#' st_irishgridrefs(x_sf, sep = " ")
st_irishgridrefs <- function(x, digits = 3, precision = NULL, sep = "") {
  if (!inherits(x, "sf")) {
    stop_custom("not_sf", "x must be an sf object")
  }
  if (sf::st_geometry_type(x, by_geometry = FALSE) != "POINT") {
    stop_custom("not_sf_POINT", "x must contain only geometry type POINT")
  }
  if (is.na(digits) & is.null(precision)) {
    stop_custom("no_precision", "precision or digits must be specified")
  }
  if (!is.null(precision)) {
    if (!precision %in% valid_precisions) {
      stop_custom(
        "unsupported_precision",
        paste("precision must be one of: ", valid_precisions, ".")
      )
    }
  }

  res <- x |>
    sf::st_transform(crs = 29903) |>
    sf::st_coordinates() |>
    ig_to_igr(digits = digits, precision = precision, sep = sep)

  return(res)
}
