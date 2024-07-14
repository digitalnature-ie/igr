#' Convert Irish Grid coordinates to Irish grid references
#'
#' `ig_to_igr()` returns the Irish grid references for valid Irish Grid
#' (EPSG:29903) coordinates, otherwise NA.
#'
#' @param x a matrix containing Irish Grid eastings and northings in the first
#'   and second columns respectively.
#' @param digits an integer, the number of digits for both easting and northing
#'   in the Irish grid references. 0 is equivalent to a precision of 100 km, 1:
#'   10 km, 2: 1 km, 3: 100 m, 4: 10 m, and 5: 1 m.
#' @param sep a character to separate the 100 km grid letter, easting, and
#'   northing.
#'
#' @return A character vector of Irish grid references.
#' @export
#'
#' @examples
#' # A matrix of three Irish Grid coordinates
#' m <- matrix(c(0, 412300, 0, 98700, 456000, 0), byrow = TRUE, ncol = 2)
#'
#' m
#'
#' # Convert to Irish grid references
#' ig_to_igr(m)
#'
#' # Insert a space between the 100 km grid letter, easting, and northing
#' ig_to_igr(m, sep = " ")
#'
#' # Convert into Irish grid references with 1 km precision
#' ig_to_igr(m, digits = 2)
ig_to_igr <- function(x, digits = 3, sep = "") {
  x <- as.matrix(x) # in case a data.frame

  if (ncol(x) < 2) {
    stop_custom("not_x_y", "x must contain at least two columns")
  }

  # if x or y non-numeric then later expressions will error so catch now
  tryCatch(
    {
      x <- matrix(as.numeric(x[, 1:2]), ncol = 2) # keep first two columns
    },
    warning = function(w) {
      stop_custom("non_numeric_x_y", "the first 2 columns of x must be numeric")
    }
  )

  # look up 100km grid reference
  igr_letters <- mapply(lookup_igr_100,
    x = x[, 1],
    y = x[, 2]
  )

  invalid <- is.na(igr_letters)

  if (any(invalid)) {
    warning(
      "Invalid Irish Grid coordinates detected: ",
      ifelse(
        length(which(invalid)) > 10,
        paste0(
          paste0("(", x[invalid, 1][1:10], ", ", x[invalid, 2][1:10], ")",
            collapse = ", "
          ), ", ..."
        ),
        paste0("(", x[invalid, 1], ",", x[invalid, 2], ")", collapse = ", ")
      )
    )
  }

  # calculate x and y offsets within 100km square to required precision
  offsets <- x %% 100000 |>
    formatC(width = 5, format = "d", flag = "0") |>
    substr(1, digits)

  # TODO: Convert digits to precision to allow tetrads in the future
  
  # concatenate into Irish Grid References
  res <- ifelse(
    invalid,
    NA_character_,
    paste(igr_letters, offsets[, 1], offsets[, 2], sep = sep)
  )

  return(res)
}
