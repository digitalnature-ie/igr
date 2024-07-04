#' Convert data frame containing Irish Grid References to an sf object
#'
#' @param x object to be converted into an object class sf. Must not contain columns specified in coords.
#' @param igrefs name or number of the character column holding Irish Grid References.
#' @param crs coordinate reference system to be assigned; object of class crs.
#' @param remove logical; remove Irish Grid References column?
#' @param add_coords logical; add Irish Grid coordinate columns?
#' @param coords A character vector of column names to contain the Irish Grid easting and northing.
#' @param res The name of column to contain grid reference resolution, if required.
#' @param polygons return polygon objects spanning the extent of each grid reference, rather than point objects.
#'
#' @return An sf object.
#' @export
#'
#' @examples
#' x <- data.frame(igr = c("A00", "N8000"))
#' st_igr_as_sf(x, "igr")
#' st_igr_as_sf(x, "igr", crs = 4326)
st_igr_as_sf <- function(x, igrefs, crs = 29903, remove = FALSE, add_coords = FALSE, coords = c("x", "y"), res = NULL, polygons = FALSE) {
  # if x includes column names coords then stop
  coords_existing <- intersect(colnames(x), coords)
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

  if (polygons) {
    # need resolution of each grid reference
    ig <- igr_to_ig(x[[igrefs]], coords = coords, res = "res") 
    
    # calculate centre of square of each grid reference
    ig[[1]] <- ig[[1]] + (ig[[3]] / 2) # x = x + 1/2 resolution
    ig[[2]] <- ig[[2]] + (ig[[3]] / 2) # y = y + 1/2 resolution
    
    # generate square for each grid reference
    res_sf <- cbind(x, ig) |>
      sf::st_as_sf(coords = coords, crs = 29903, remove = !add_coords) |>
      sf::st_buffer(dist = ig$res/2, endCapStyle = "SQUARE") |>
      sf::st_transform(crs = crs)
    
    # remove res column if was not requested
    if (is.null(res)) {
      res_sf <- res_sf[, !names(res_sf) == res]
    }
    
  } else {
    ig <- as.data.frame(igr_to_ig(x[[igrefs]], coords = coords, res = res))
    
    res_sf <- cbind(x, ig) |>
      sf::st_as_sf(coords = coords, crs = 29903, remove = !add_coords) |>
      sf::st_transform(crs = crs)
  }

  if (remove) {
    res_sf <- res_sf[, !names(res_sf) == igrefs]
  }

  return(res_sf)
}
