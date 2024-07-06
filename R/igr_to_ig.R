#' Convert Irish grid references to Irish Grid coordinates
#'
#' `igr_to_ig()` converts Irish grid references into a list of Irish Grid
#' (EPSG:29903) x and y coordinates and (optionally) grid reference resolutions
#' in metres.
#'
#' @param x A character vector of Irish grid references. Irish grid references
#'   consist of a letter (other than I) optionally followed by both an easting
#'   and northing. The easting and northing must be of the same length of
#'   between 1 and 5 digits. There may be whitespace between the letter, easting
#'   and northing.
#' @param coords A character vector of column names for easting and northing.
#' @param res A character vector: the column name for resolution of original
#'   grid reference in metres, if required.
#'
#' @return A list containing Irish Grid x and y coordinates and (optionally)
#'   the resolution in metres of each Irish grid reference. Invalid Irish grid
#'   references return NA.
#' @export
#'
#' @examples
#' # A vector of three Irish grid references of different resolutions
#' v <- c("N8090", "D1234588800", "W34")
#' 
#' # Convert to Irish Grid coordinates
#' igr_to_ig(v)
#'
#' # Specify column names
#' igr_to_ig(v, coords = c("e", "n"))
#'
#' # Also return the resolution in metres of each grid reference
#' igr_to_ig(v, res = "res")
igr_to_ig <- function(x, coords = c("x", "y"), res = NULL) {
  if (is.null(x)) {
    return(list(x = double(), y = double()))
  }

  invalid <- !grepl("^\\s*[a-h,j-z,A-H,J-Z]\\s*(()|(\\d\\s*\\d)|(\\d{2}\\s*\\d{2})|(\\d{3}\\s*\\d{3})|(\\d{4}\\s*\\d{4})|(\\d{5}\\s*\\d{5}))\\s*$", x)

  if (any(invalid)) {
    warning(
      "Invalid Irish grid references detected: ",
      ifelse(
        length(which(invalid)) > 10,
        paste0(paste(x[invalid][1:10], collapse = ", "), ", ..."),
        paste(x[invalid], collapse = ", ")
      )
    )
    # stop_custom(
    #   "bad_input",
    #   paste(
    #     "igr must be a valid Irish Grid Reference: a letter (other than I) optionally followed by an easting and northing, both the same length, of between 1 and 5 digits.",
    #     ifelse(
    #       length(which(invalid)) > 10,
    #       paste0(paste(x[invalid][1:10], collapse = ", "), ", ..."),
    #       paste(x[invalid], collapse = ", ")
    #     ),
    #     ifelse(length(which(invalid)) == 1, "is", "are"),
    #     "invalid."
    #   )
    # )
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

  if (is.null(res)) {
    ig <- list(ig_x, ig_y)
    names(ig) <- coords[1:2]
  } else {
    ig <- list(ig_x, ig_y, igr_res)
    names(ig) <- c(coords, res)
  }

  return(ig)
}
