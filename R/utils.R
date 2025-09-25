# Irish Grid 100 km squares
igr_100 <- list(
  letter = LETTERS[-9], # Letter reference (no I)
  x = rep(c(0:4) * 100000, 5), # SW corner easting in metres
  y = rep(c(4:0), each = 5) * 100000 # SW corner northing in metres
)

# tetrad offsets
igr_tetrad <- list(
  letter = LETTERS[-15], # Letter reference (no O)
  x = rep(c(0:4), each = 5) * 2000, # SW corner easting in metres
  y = rep(c(0:4), 5) * 2000 # SW corner northing in metres
)

# Supported precisions of Irish grid references in metres
valid_precisions <- c(1, 10, 100, 1000, 2000, 10000, 100000)

#' Lookup 100 km Irish grid reference for Irish Grid coordinate
#'
#' @param x Irish Grid easting.
#' @param y Irish Grid northing.
#'
#' @return Letter indicating the 100 km Irish Grid squares containing the
#'   coordinate, or NA for a missing or invalid Irish Grid coordinate.
#'
#' @noRd
lookup_igr_100 <- function(x, y) {
  if (!is.numeric(x) | x < 0 | x >= 500000 | is.nan(x) |
      !is.numeric(y) | y < 0 | y >= 500000 | is.nan(y)) {
    NA_character_
  } else {
    igr_100$letter[
      (igr_100$x / 100000 == (x %/% 100000)) &
        (igr_100$y / 100000 == (y %/% 100000))
    ]
  }
}

#' Lookup tetrad for Irish Grid coordinate
#'
#' @param x Irish Grid easting.
#' @param y Irish Grid northing.
#'
#' @return Letter indicating the tetrad containing the
#'   coordinate, or NA_character_ for an invalid Irish Grid coordinate.
#'
#' @noRd
lookup_tetrad <- function(x, y) {
  if (!is.numeric(x) | x < 0 | x >= 500000 |
      !is.numeric(y) | y < 0 | y >= 500000) {
    NA_character_
  } else {
    igr_tetrad$letter[
      (igr_tetrad$x == (x %% 10000) - (x %% 2000)) &
      (igr_tetrad$y == (y %% 10000) - (y %% 2000))
    ]
    
  }
}

#' Create custom error subclass
#'
#' @param .subclass Name of the error subclass.
#' @param message Error message.
#' @param call The call generating the error.
#' @param ... Additional parameters to be passed into the error subclass.
#'
#' @noRd
stop_custom <- function(.subclass, message, call = NULL, ...) {
  err <- structure(list(message = message, call = call, ...),
    class = c(.subclass, "error", "condition")
  )
  stop(err)
}
