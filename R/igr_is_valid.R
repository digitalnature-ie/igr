#' Check if Irish grid references are valid
#'
#' `igr_is_valid()` identifies valid Irish grid references.
#'
#' Valid Irish grid references consist of a letter (other than I) optionally
#' followed by both an easting and northing. The easting and northing must be of
#' the same length of between 1 and 5 digits. There may be whitespace between
#' the letter, easting and northing.
#'
#' The tetrad form of Irish grid reference consists of a valid 10 km precision
#' Irish grid reference (one letter, one digit easting and one digit northing)
#' followed by a letter (other than O). This refers to a 2 km square within the
#' 10 km square referenced.
#'
#' @param x A character vector of Irish grid references.
#' @param tetrad Permit tetrad form of Irish grid reference?
#'
#' @return A logical vector indicating the validity of each Irish grid
#'   reference.
#' @export
#'
#' @examples
#' # A vector of alternating valid and invalid Irish grid references
#' v <- c("N8090", "D 12 345 88800", "W34", "I30", "W", "A123", "B1234", "", "A12Z", "A12O")
#'
#' # Check validity of Irish Grid coordinates
#' igr_is_valid(v)
#'
#' # Check validity of Irish Grid coordinates, dissallowing tetrad form
#' igr_is_valid(v, tetrad = FALSE) 
igr_is_valid <- function(x, tetrad = TRUE) {
  if (is.null(x)) {
    return(NULL)
  }

  valid <- grepl(
    paste0(
      "^\\s*", # ignore whitespace at start
      "[A-H,J-Z]\\s*(()|", # 100 km
      "(\\d\\s*\\d)|", # 10 km
      ifelse(tetrad, "(\\d\\s*\\d\\s*[A-N,P-Z])|", ""), # 10 km tetrad
      "(\\d{2}\\s*\\d{2})|", # 1 km
      "(\\d{3}\\s*\\d{3})|", # 100 m
      "(\\d{4}\\s*\\d{4})|", # 10 m
      "(\\d{5}\\s*\\d{5}))", # 1 m
      "\\s*$" # ignore whitespace at end
    ),
    x,
    ignore.case = TRUE
  )

  return(valid)
}
