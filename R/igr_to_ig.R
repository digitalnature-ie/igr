igr100_letters <- LETTERS[-9] # Irish Grid 100km Square letters (no "I")
igr100_e <- rep(c(0:4) * 100000, 5) # Irish Grid 100km Square SW corner Easting in metres
igr100_n <- rep(c(4:0), each = 5) * 100000 # Irish Grid 100km Square SW corner Northing in metres

stop_custom <- function(.subclass, message, call = NULL, ...) {
  err <- structure(list(message = message, call = call, ...),
                   class = c(.subclass, "error", "condition"))
  stop(err)
}


#TODO return tibble? dataframe?
#TODO documentation
#TODO hex
#TODO badges

igr_to_ig <- function(igr) {
  #igr = c("A00", "B00", "1", "1", "1", "1", "1", "1", "1", "2", "3", "4", "5")
  
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
  
  igr100_index <- match(igr_letter, igr100_letters)
  
  igr_len <- nchar(igr)
  res <- (igr_len - 1) / 2
  
  # calculate offset within the 100km grid
  offset_e <- ifelse(igr_len == 1, 0, as.integer(substring(igr, 2, 1 + res)) * 10 ^
                       (5 - res))
  
  offset_n <- ifelse(igr_len == 1, 0, as.integer(substring(igr, 2 + res)) * 10 ^
                       (5 - res))
  
  # calculate full Irish Grid coordinates
  ig_e <- igr100_e[igr100_index] + offset_e
  ig_n <- igr100_n[igr100_index] + offset_n
  
  # res <- tibble::tibble(ig_e, ig_n)
  
  res <- c(e = ig_e, n = ig_n)
  
  return(res)
}
