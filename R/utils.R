# Irish Grid 100 km squares
igr_100 <- list(
  letter = LETTERS[-9], # Letter reference (no I)
  x = rep(c(0:4) * 100000, 5), # SW corner easting in metres
  y = rep(c(4:0), each = 5) * 100000 # SW corner northing in metres
)

lookup_igr_100 <- function(x, y) {
  if (!is.numeric(x) | x < 0 | x >= 500000 |
    !is.numeric(y) | y < 0 | y >= 500000) {
    NA_character_
  } else {
    igr_100$letter[
      (igr_100$x / 100000 == (x %/% 100000)) &
        (igr_100$y / 100000 == (y %/% 100000))
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
