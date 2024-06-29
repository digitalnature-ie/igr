#' Convert data frame containing Irish Grid References to an sf object
#'
#' @param data data to be converted into an object class sf
#' @param igrefs column holding irish grid references
#' @param crs coordinate reference system to be assigned; object of class crs
#' @param remove logical; remove irish grid references column from data.frame?
#' @param add_coords logical; add irish grid coordinates x and y columns to data.frame?
#'
#' @return An sf object.
#' @export
#'
#' @examples
#' x <- data.frame(igr = c("A00", "N8000"))
#' igr_as_sf(x, igr)
#' igr_as_sf(x, igr, crs = 4326)
igr_as_sf <- function(data, igrefs, crs = 29903, remove = FALSE, add_coords = FALSE) {
  # TODO igrefs as character? as column number?

  res <- data |>
    dplyr::mutate(igr_to_ig({{ igrefs }})) |>
    sf::st_as_sf(coords = c("x", "y"), crs = 29903, remove = !add_coords) |>
    sf::st_transform(crs = crs)

  if (remove) {
    res <- res |>
      dplyr::select(-{{ igrefs }})
  }

  return(res)
}
