#' Convert Irish grid references to Irish Grid coordinates
#'
#' `igr_to_ig()` converts Irish grid references into a list of Irish Grid
#' (EPSG:29903) X and Y coordinates. By default the coordinates of the south
#' west corners of each Irish grid reference are calculated. The precision of each
#' Irish grid reference in metres can be returned.
#'
#' @inheritParams igr_is_valid
#' @param x A character vector of Irish grid references. See [igr_is_valid()]
#'   for a definition of valid Irish grid references.
#' @param coords A character vector of the names of the columns to contain the
#'   Irish Grid X and Y coordinates respectively.
#' @param centroids Should the coordinates of the centroids of the Irish grid
#'   references be returned (rather than the south west corners)?
#' @param precision The name of the column to contain the precision of each
#'   Irish grid reference in metres, if required.
#'
#' @return A list containing Irish Grid X and Y coordinates and, optionally, the
#'   precision in metres of each Irish grid reference. Invalid or missing Irish
#'   grid references return NA.
#' @export
#'
#' @examples
#' # A vector of Irish grid references of different precisions
#' v <- c("N8090", "D1234588800", "W34", "", "D12T")
#'
#' # Convert south west corners of Irish grid references to Irish Grid coordinates
#' igr_to_ig(v)
#'
#' # Convert centroids of Irish grid references to Irish Grid coordinates
#' igr_to_ig(v, centroids = TRUE)
#' 
#' # Specify column names
#' igr_to_ig(v, coords = c("e", "n"))
#'
#' # Also return the precision in metres of each Irish grid reference
#' igr_to_ig(v, precision = "prec")
igr_to_ig <- function(x, coords = c("x", "y"), centroids = FALSE, precision = NULL, tetrad = TRUE) {
  if (is.null(x)) {
    return(list(x = double(), y = double()))
  } else if (length(coords) != 2) {
    stop_custom(
      "invalid_coord_names",
      paste("coords must be a vector of two strings to name the X and Y columns.")
    )
  }

  invalid <- !igr_is_valid(x, tetrad)

  if (any(invalid)) {
    warning(
      "Invalid Irish grid references detected: ",
      ifelse(
        length(which(invalid)) > 10,
        paste0(paste(x[invalid][1:10], collapse = ", "), ", ..."),
        paste(x[invalid], collapse = ", ")
      )
    )
  }

  igr <- gsub(" ", "", x, fixed = TRUE)

  igr_len <- nchar(igr)

  igr_letter <- toupper(substring(igr, 1, 1))
  igr_tetrad_letter <- toupper(substring(igr, 4, 4))

  igr_100_index <- match(igr_letter, igr_100$letter)
  igr_tetrad_index <- match(igr_tetrad_letter, igr_tetrad$letter, nomatch = 1) # if not a tetrad add no offset just like tetrad "A", index 1

  igr_digits <- ifelse(invalid, NA_integer_, trunc((igr_len - 1) / 2)) # trunc() in case tetrad
  igr_base_res <- 10^(5 - igr_digits) # resolution ignoring tetrad
  igr_res <- ifelse(igr_len != 4, igr_base_res, 2000) # resolution including tetrad
  
  # calculate 1 m offset within the 100 km grid for the base grid reference
  offset_x <- ifelse(invalid, NA_integer_, ifelse(igr_len == 1, 0, as.integer(substring(igr, 2, 1 + igr_digits)) * igr_base_res))
  offset_y <- ifelse(invalid, NA_integer_, ifelse(igr_len == 1, 0, as.integer(substring(igr, 2 + igr_digits, 1 + igr_digits + igr_digits)) * igr_base_res))

  if(centroids) {
    offset_x <- offset_x + igr_res/2
    offset_y <- offset_y + igr_res/2
  }
  
  # calculate full Irish Grid coordinates to 1 m, including any tetrad offset
  ig_x <- ifelse(invalid, NA_integer_, igr_100$x[igr_100_index] + offset_x + igr_tetrad$x[igr_tetrad_index])
  ig_y <- ifelse(invalid, NA_integer_, igr_100$y[igr_100_index] + offset_y + igr_tetrad$y[igr_tetrad_index])

  if (is.null(precision)) {
    ig <- list(ig_x, ig_y)
    names(ig) <- coords
  } else {
    ig <- list(ig_x, ig_y, igr_res)
    names(ig) <- c(coords, precision)
  }

  return(ig)
}
