#' Convert Irish Grid References to Irish Grid coordinates
#'
#' @param x A character vector of Irish Grid references.
#' @param coords A character vector of column names to contain the easting and northing.
#'
#' @return A list of Irish Grid coordinates.
#' @export
#'
#' @examples
#' igr_to_ig("A00")
#' igr_to_ig(c("N8090", "D1234588800"))
igr_to_ig <- function(x, coords = c("x", "y")) {
  # igr <- "A00"

  invalid <- !grepl("^[a-h,j-z,A-H,J-Z]([0-9][0-9]){0,5}$", x)

  if (any(invalid)) {
    stop_custom(
      "bad_input",
      paste(
        "igr must be a valid Irish Grid Reference: a letter (other than I) followed by an even number of digits.",
        ifelse(
          length(invalid) > 10,
          paste0(paste(x[invalid][1:10], collapse = ", "), ", ..."),
          paste(x[invalid], collapse = ", ")
        ),
        ifelse(length(invalid) == 1, "is", "are"),
        "invalid."
      )
    )
  }

  igr_letter <- substring(x, 1, 1)

  igr_100_index <- match(igr_letter, igr_100$letter)

  igr_len <- nchar(x)
  res <- (igr_len - 1) / 2

  # calculate offset within the 100km grid
  offset_x <- ifelse(igr_len == 1, 0, as.integer(substring(x, 2, 1 + res)) * 10^
    (5 - res))

  offset_y <- ifelse(igr_len == 1, 0, as.integer(substring(x, 2 + res)) * 10^
    (5 - res))

  # calculate full Irish Grid coordinates
  ig_x <- igr_100$x[igr_100_index] + offset_x
  ig_y <- igr_100$y[igr_100_index] + offset_y


  #res <- data.frame(x = ig_x, y = ig_y)

  res <- list(ig_x,ig_y)
  names(res) <- coords
  
  return(res)
}
