#' Convert data frame containing Irish grid references to an sf object
#'
#' `st_igr_as_sf()` transforms Irish grid references into an sf object
#' containing point or polygon features. Points are the south west corner of the
#' grid references. Polygons are Irish Grid squares covering the full extent of
#' the grid references, each square size depending on the precision of each grid
#' reference. The Irish Grid (EPSG:29903) x and y coordinates and grid reference
#' precision in metres can be appended.
#'
#' @inheritParams igr_to_ig
#' @param x object containing column of Irish grid references. Must not contain
#'   columns specified in `coords`, or invalid Irish grid references.
#' @param igrefs string (column name) or number (column index) of the character
#'   column holding Irish grid references.
#' @param crs object of class crs containing the coordinate reference system to
#'   be assigned. See [sf::st_crs()].
#' @param remove a logical indicating if the column containing the Irish grid
#'   references should be removed.
#' @param add_coords a logical indicating if Irish Grid coordinate columns
#'   should be added.
#' @param polygons a logical indicating if polygon features spanning the extent
#'   of each grid reference should be returned, rather than point features.
#'
#' @return An sf object containing point or polygon features for each Irish grid
#'   reference in x.
#' @export
#'
#' @examples
#' # A data.frame containing two Irish grid references
#' x <- data.frame(igr = c("A00", "N8000"))
#'
#' # Convert a data.frame of Irish grid references to an sf object in the
#' # Irish Grid coordinate reference system
#' st_igr_as_sf(x, "igr")
#'
#' # Convert to an sf object in the WGS 84 coordinate reference system
#' st_igr_as_sf(x, "igr", crs = 4326)
#'
#' # Include the Irish Grid coordinates and precision in the sf object
#' st_igr_as_sf(x, "igr", add_coords = TRUE, precision = "prec")
#'
#' # Convert into polygons rather than points
#' st_igr_as_sf(x, "igr", polygons = TRUE)
#'
st_igr_as_sf <- function(
    x,
    igrefs = "igr",
    crs = 29903,
    remove = FALSE,
    add_coords = FALSE,
    coords = c("x", "y"),
    precision = NULL,
    polygons = FALSE) {
  # if x includes column names in coords then stop
  coords_existing <- intersect(colnames(x), coords)
  if (length(coords_existing) > 0) {
    stop_custom(
      "bad_input",
      paste(
        "Column(s)",
        paste(coords_existing, collapse = " "),
        "detected. Remove, or use coords argument to specify alternative(s)."
      )
    )
  }

  if (polygons) {
    igr_precision <- "prec"
  } # grid reference precision is required
  else {
    igr_precision <- precision
  }

  # later sf processing cannot handle missing values so catch warning and
  # raise as error
  tryCatch(
    {
      ig <- igr_to_ig(x[[igrefs]], coords = coords, precision = igr_precision)
    },
    warning = function(w) {
      stop_custom(
        "bad_grid_ref",
        paste(
          "Cannot generate sf objects containing missing values.",
          w$message
        )
      )
    }
  )

  if (polygons) {
    # calculate centre of square of each grid reference
    ig[[1]] <- ig[[1]] + (ig[[3]] / 2) # x = x + 1/2 resolution
    ig[[2]] <- ig[[2]] + (ig[[3]] / 2) # y = y + 1/2 resolution

    # generate square for each grid reference
    res_sf <- cbind(x, ig) |>
      sf::st_as_sf(coords = coords, crs = 29903, remove = !add_coords) |>
      sf::st_buffer(dist = ig$prec / 2, endCapStyle = "SQUARE") |>
      sf::st_transform(crs = crs)

    if (is.null(precision)) {
      # remove precision column
      res_sf <- res_sf[, !names(res_sf) == "prec"]
    } else {
      # rename res column
      names(res_sf)[names(res_sf) == "prec"] <- precision
    }
  } else {
    ig <- as.data.frame(ig)

    res_sf <- cbind(x, ig) |>
      sf::st_as_sf(coords = coords, crs = 29903, remove = !add_coords) |>
      sf::st_transform(crs = crs)
  }

  if (remove) {
    res_sf <- res_sf[, !names(res_sf) == igrefs]
  }

  return(res_sf)
}
