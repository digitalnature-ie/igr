#' Convert Irish Grid coordinates to Irish Grid References
#'
#' @param x a list of two character vectors containing Irish Grid eastings and northings respectively.
#' @param digits the resolution of grid reference required, between 0 (100km) and 6 (1m).
#' @param sep a character to separate the 100km grid letter, easting, and northing.
#' 
#' @return A character vector of Irish Grid References.
#' @export
#'
#' @examples
#' ig_to_igr(list(x = 0, y = 0))
#' ig_to_igr(list(x = c(0, 400000), y = c(0, 40000)))
ig_to_igr <- function(x, digits = 3, sep = "") {
  x <- matrix(unlist(x), ncol = 2)

  # look up 100km grid reference
  letters <- mapply(lookup_igr_100,
    x = x[, 1],
    y = x[, 2]
  )

  # calculate x and y offsets within 100km square to required resolution
  offsets <- x %% 100000 |>
    formatC(width = 5, format = "d", flag = "0") |>
    substr(1, digits)

  # concatenate into Irish Grid References
  res <- paste(letters, offsets[, 1], offsets[, 2], sep = sep)

  return(res)
}


# ig_to_igr <- function(x, digits = 3) {
#   # look up 100km grid reference
#   letters <- mapply(lookup_igr_100,
#                     x = x[, 1],
#                     y = x[, 2]
#   )
#
#   # calculate x and y offsets within 100km square to required resolution
#   offsets <- x %% 100000 |>
#     formatC(width = 5, format = "d", flag = "0") |>
#     substr(1, digits)
#
#   # concatenate into Irish Grid References
#   res <- paste0(letters, offsets[, 1], offsets[, 2])
#
#   return(res)
# }
