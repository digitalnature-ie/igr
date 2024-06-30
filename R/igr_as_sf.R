#' Convert data frame containing Irish Grid References to an sf object
#'
#' @param data data to be converted into an object class sf. Must not contain columns specified in coords.
#' @param igrefs name or number of the character column holding Irish Grid References.
#' @param crs coordinate reference system to be assigned; object of class crs.
#' @param remove logical; remove Irish Grid References column?
#' @param add_coords logical; add Irish Grid coordinate columns?
#' @param coords A character vector of column names to contain the Irish Grid easting and northing.
#'
#' @return An sf object.
#' @export
#'
#' @examples
#' x <- data.frame(igr = c("A00", "N8000"))
#' igr_as_sf(x, "igr")
#' igr_as_sf(x, "igr", crs = 4326)
igr_as_sf <- function(data, igrefs, crs = 29903, remove = FALSE, add_coords = FALSE, coords = c("x", "y")) {
  # if data includes column names coords then stop
  coords_existing <- intersect(colnames(data), coords)
  if (length(coords_existing) > 0) {
    stop_custom(
      "bad_input",
      paste("Existing column(s)", paste(coords_existing, collapse = " "), "present. Remove, or use coords argument to specify alternative(s).")
    )
  }

  # Irish grid references column (igrefs) could be supplied as
  # (A) quoted column name or unquoted column number, or
  # (B) as unquoted column name.
  # It appears
  # (A) is more traditional base r, does not require importing dplyr as dependency, and is approach followed by sf::st_as_sf() arguments coords and wkt.
  # (B) is more tidyr friendly.
  # The code below implements (A). If needed, (B) would require code such as
  #     dplyr::mutate(as.data.frame(igr_to_ig({{ igrefs }})))
  #     dplyr::select(-{{ igrefs }})

  res <- cbind(data, as.data.frame(igr_to_ig(data[[igrefs]], coords = coords))) |>
    sf::st_as_sf(coords = coords, crs = 29903, remove = !add_coords) |>
    sf::st_transform(crs = crs)

  if (remove) {
    res[[igrefs]] <- NULL
  }

  return(res)
}
