#' Convert Irish grid references to Irish Grid coordinates
#'
#' `igr_to_ig()` converts Irish grid references into a list of Irish Grid
#' (EPSG:29903) X and Y coordinates. The precision of each Irish grid reference
#' in metres can be returned.
#'
#' @param x A character vector of Irish grid references. See [igr_is_valid()]
#'   for a definition of valid Irish grid references.
#' @param coords A character vector of the names of the columns to contain the
#'   Irish Grid X and Y coordinates respectively.
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
#' v <- c("N8090", "D1234588800", "W34", "")
#'
#' # Convert to Irish Grid coordinates
#' igr_to_ig(v)
#'
#' # Specify column names
#' igr_to_ig(v, coords = c("e", "n"))
#'
#' # Also return the precision in metres of each Irish grid reference
#' igr_to_ig(v, precision = "prec")
igr_to_ig <- function(x, coords = c("x", "y"), precision = NULL) {
  if (is.null(x)) {
    return(list(x = double(), y = double()))
  }

  invalid <- !igr_is_valid(x)

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

  igr_letter <- toupper(substring(igr, 1, 1))

  igr_100_index <- match(igr_letter, igr_100$letter)

  igr_len <- nchar(igr)
  igr_digits <- ifelse(invalid, NA_integer_, (igr_len - 1) / 2)
  igr_res <- 10^(5 - igr_digits)

  # calculate 1m offset within the 100km grid
  offset_x <- ifelse(invalid, NA_integer_, ifelse(igr_len == 1, 0, as.integer(substring(igr, 2, 1 + igr_digits)) * igr_res))
  offset_y <- ifelse(invalid, NA_integer_, ifelse(igr_len == 1, 0, as.integer(substring(igr, 2 + igr_digits)) * igr_res))

  # calculate full Irish Grid coordinates to 1m
  ig_x <- ifelse(invalid, NA_integer_, igr_100$x[igr_100_index] + offset_x)
  ig_y <- ifelse(invalid, NA_integer_, igr_100$y[igr_100_index] + offset_y)

  if (is.null(precision)) {
    ig <- list(ig_x, ig_y)
    names(ig) <- coords[1:2]
  } else {
    ig <- list(ig_x, ig_y, igr_res)
    names(ig) <- c(coords, precision)
  }

  return(ig)
}
