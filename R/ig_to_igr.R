#' Convert Irish Grid coordinates to Irish grid references
#'
#' `ig_to_igr()` returns the Irish grid references at the specified precision
#' for valid Irish Grid (EPSG:29903) coordinates, otherwise NA.
#'
#' Either `digits` or `precision` must be specified. `precision` overrides
#' `digits`.
#'
#' @param x a matrix containing Irish Grid eastings and northings in the first
#'   and second columns respectively.
#' @param digits an integer, the number of digits for both easting and northing
#'   in the Irish grid references.
#'   * `0`: equivalent to a precision of 100 km.
#'   * `1`: equivalent to a precision of 10 km.
#'   * `2`: equivalent to a precision of 1 km.
#'   * `3` (the default): equivalent to a precision of 100 m.
#'   * `4`: equivalent to a precision of 10 m.
#'   * `5`: equivalent to a precision of 1 m.
#' @param precision an integer, the precision of the Irish grid references in
#'   metres: `1`, `10`, `100`, `1000`, `10000`, or `100000`. Overrides `digits`.
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
#' # Convert into Irish grid references with 1 km precision (2 digit easting and northing)
#' ig_to_igr(m, precision = 1000)
#'
#' # Convert into Irish grid references with 4 digit easting and northing (10 m precision)
#' ig_to_igr(m, digits = 4)
ig_to_igr <- function(x, digits = 3, precision = NULL, sep = "") {
  if (is.na(digits) & is.null(precision)) {
    stop_custom("no_precision", "precision or digits must be specified")
  }
  if (!is.null(precision)) {
    if(!precision %in% valid_precisions) {
      stop_custom(
        "unsupported_precision", 
        paste("precision must be one of: ", valid_precisions, ".")  
      )
    }
  }
  
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
    strtrim(ifelse(is.null(precision), digits, 5 - log10(precision)))
  
  # concatenate into Irish Grid References
  res <- ifelse(
    invalid,
    NA_character_,
    paste(igr_letters, offsets[, 1], offsets[, 2], sep = sep)
  )

  return(res)
}
