# Irish Grid 100km squares
igr_100 <- list(
  letter = LETTERS[-9], # Letter reference (no I)
  x = rep(c(0:4) * 100000, 5), # SW corner Easting in metres
  y = rep(c(4:0), each = 5) * 100000 # SW corner Northing in metres
)


stop_custom <- function(.subclass, message, call = NULL, ...) {
  err <- structure(list(message = message, call = call, ...),
    class = c(.subclass, "error", "condition")
  )
  stop(err)
}


# TODO hex
# TODO badges
# TODO transform into sf? with optional crs?

#' Title
#'
#' @param igr A character vector of Irish Grid References.
#'
#' @return A something of Irish Grid coordinates.
#' @export
#'
#' @examples
#' igr_to_ig("A00")
#' igr_to_ig(c("N8090", "D1234588800"))
igr_to_ig <- function(igr) {
  # igr <- "A00"

  invalid <- !grepl("^[a-h,j-z,A-H,J-Z]([0-9][0-9]){0,5}$", igr)

  if (any(invalid)) {
    stop_custom(
      "bad_input",
      paste(
        "igr must be a valid Irish Grid Reference: a letter (other than I) followed by an even number of digits.",
        ifelse(
          length(invalid) > 10,
          paste0(paste(igr[invalid][1:10], collapse = ", "), ", ..."),
          paste(igr[invalid], collapse = ", ")
        ),
        ifelse(length(invalid) == 1, "is", "are"),
        "invalid."
      )
    )
  }

  igr_letter <- substring(igr, 1, 1)

  igr_100_index <- match(igr_letter, igr_100$letter)

  igr_len <- nchar(igr)
  res <- (igr_len - 1) / 2

  # calculate offset within the 100km grid
  offset_x <- ifelse(igr_len == 1, 0, as.integer(substring(igr, 2, 1 + res)) * 10^
    (5 - res))

  offset_y <- ifelse(igr_len == 1, 0, as.integer(substring(igr, 2 + res)) * 10^
    (5 - res))

  # calculate full Irish Grid coordinates
  ig_x <- igr_100$x[igr_100_index] + offset_x
  ig_y <- igr_100$y[igr_100_index] + offset_y


  res <- data.frame(x = ig_x, y = ig_y)

  return(res)
}
