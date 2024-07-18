#' Check if Irish grid references are valid
#'
#' `igr_is_valid()` identifies valid Irish grid references.
#'
#' Valid Irish grid references consist of a letter (other than I) optionally
#' followed by both an easting and northing. The easting and northing must be of
#' the same length of between 1 and 5 digits. There may be whitespace between
#' the letter, easting and northing.
#'
#' @param x A character vector of Irish grid references.
#'
#' @return A logical vector indicating whether for each Irish grid reference
#'   whether it is valid.
#' @export
#'
#' @examples
#' # A vector of alternating valid and invalid Irish grid references
#' v <- c("N8090", "D 12 345 88800", "W34", "I30", "W", "A123", "B1234", "")
#'
#' # Check validity of Irish Grid coordinates
#' igr_is_valid(v)
igr_is_valid <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }

  valid <- grepl(
    paste0(
      "^\\s*",   # ignore whitespace at start
      "[a-h,j-z,A-H,J-Z]\\s*(()|(\\d\\s*\\d)|(\\d{2}\\s*\\d{2})|(\\d{3}\\s*\\d{3})|(\\d{4}\\s*\\d{4})|(\\d{5}\\s*\\d{5}))",
      "\\s*$"    # ignore whitespace at end
    ),
    x)

  return(valid)
}
