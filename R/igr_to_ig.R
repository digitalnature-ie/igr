#' Convert Irish Grid References to Irish Grid coordinates
#'
#' @param x A character vector of Irish Grid references.
#' @param coords A character vector of column names for easting and northing.
#' @param res A character string for column name for resolution, if required.
#'
#' @return A list of Irish Grid coordinates.
#' @export
#'
#' @examples
#' igr_to_ig("A00")
#' igr_to_ig(c("N8090", "D1234588800"))
igr_to_ig <- function(x, coords = c("x", "y"), res = NULL) {
  invalid <- !grepl("^\\s*[a-h,j-z,A-H,J-Z]\\s*(()|(\\d\\s*\\d)|(\\d{2}\\s*\\d{2})|(\\d{3}\\s*\\d{3})|(\\d{4}\\s*\\d{4})|(\\d{5}\\s*\\d{5}))\\s*$", x)

  if (any(invalid)) {
    stop_custom(
      "bad_input",
      paste(
        "igr must be a valid Irish Grid Reference: a letter (other than I) optionally followed by an easting and northing, both the same length, of between 1 and 5 digits.",
        ifelse(
          length(which(invalid)) > 10,
          paste0(paste(x[invalid][1:10], collapse = ", "), ", ..."),
          paste(x[invalid], collapse = ", ")
        ),
        ifelse(length(which(invalid)) == 1, "is", "are"),
        "invalid."
      )
    )
  }

  igr <- gsub(" ", "", x, fixed = TRUE)

  igr_letter <- toupper(substring(igr, 1, 1))

  igr_100_index <- match(igr_letter, igr_100$letter)

  igr_len <- nchar(igr)
  igr_res <- (igr_len - 1) / 2

  # calculate offset within the 100km grid
  offset_x <- ifelse(igr_len == 1, 0, as.integer(substring(igr, 2, 1 + igr_res)) * 10^
    (5 - igr_res))

  offset_y <- ifelse(igr_len == 1, 0, as.integer(substring(igr, 2 + igr_res)) * 10^
    (5 - igr_res))

  # calculate full Irish Grid coordinates
  ig_x <- igr_100$x[igr_100_index] + offset_x
  ig_y <- igr_100$y[igr_100_index] + offset_y

  if(is.null(res)) {
    ig <- list(ig_x, ig_y)
    names(ig) <- coords[1:2]
  } else {
    ig <- list(ig_x, ig_y, 10^(5 -igr_res))
    names(ig) <- c(coords, res)
  } 
  
  return(ig)
}
