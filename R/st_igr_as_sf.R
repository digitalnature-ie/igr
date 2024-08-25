#' Convert a data frame containing Irish grid references into an sf object
#'
#' `st_igr_as_sf()` converts a data frame containing Irish grid references into
#' an sf object containing point or polygon features. If points, the south west
#' corners of the grid references are returned. If polygons, squares spanning
#' the full extent of each grid reference are returned, with each square's size
#' depending on the precision of each grid reference. The Irish Grid
#' (EPSG:29903) X and Y coordinates and grid reference precision in metres can
#' also be returned.
#'
#' @inheritParams igr_to_ig
#' @param x A data.frame containing a column of valid Irish grid references. It
#'   must not have column names specified in `coords`.
#' @param igrefs The name or index of the character column holding Irish grid
#'   references.
#' @param crs A valid EPSG value (numeric), a string accepted by GDAL, or an
#'   object of class crs containing the coordinate reference system to be
#'   assigned. See [sf::st_crs()].
#' @param remove Should the column containing the Irish grid references be
#'   removed from the result?
#' @param add_coords Should the Irish Grid coordinates with column names
#'   specified by `coords` be included in the result?
#' @param polygons If `FALSE` (the default) the result will contain point
#'   features located at the south-west corner of each Irish grid reference. If
#'   `TRUE` the result will contain polygon features spanning the extent of each
#'   Irish grid reference.
#'
#' @return An sf object containing point or polygon features for each Irish grid
#'   reference in x.
#' @export
#'
#' @examples
#' # A data.frame containing Irish grid references
#' x <- data.frame(igr = c("A00", "N8000", "D12T"))
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
#' # Convert into polygon features rather than point features
#' st_igr_as_sf(x, "igr", polygons = TRUE)
#'
st_igr_as_sf <- function(
    x,
    igrefs = "igr",
    crs = 29903,
    remove = FALSE,
    add_coords = FALSE,
    coords = c("x", "y"),
    centroids = FALSE,
    precision = NULL,
    polygons = FALSE,
    tetrad = TRUE) {
  if (!inherits(x, "data.frame")) {
    stop_custom("not_df", "x must be a data.frame object")
  }
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
  if (is.null(x[[igrefs]])) {
    stop_custom("missing_igrefs", paste("igrefs column", igrefs, "does not exist."))
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
      ig <- igr_to_ig(
        x[[igrefs]],
        coords = coords,
        centroids = centroids,
        precision = igr_precision,
        tetrad = tetrad
      )
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
    # calculate centre of square of each grid reference. Cannot calculate it in 
    # call to igr_to_ig() in case add_coords is TRUE and centroids is FALSE
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
      # rename precision column
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
