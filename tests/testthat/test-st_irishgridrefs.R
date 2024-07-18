x1_df <- data.frame(x = c(0), y = c(400000))
x1_sf <- sf::st_as_sf(x1_df, crs = 29903, coords = c("x", "y"))
x2_sf <- sf::st_as_sf(data.frame(x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
xe_sf <- x2_sf |> sf::st_buffer(1)

test_that("basic generations", {
  expect_equal(st_irishgridrefs(x1_sf), c("A000000"))
  expect_equal(st_irishgridrefs(x2_sf), c("A000000", "Z900000"))
})

test_that("all resolutions 100km > 1m", {
  expect_equal(st_irishgridrefs(x1_sf, precision = 100000), c("A"))
  expect_equal(st_irishgridrefs(x1_sf, precision = 10000), c("A00"))
  expect_equal(st_irishgridrefs(x1_sf, precision = 1000), c("A0000"))
  expect_equal(st_irishgridrefs(x1_sf, precision = 100), c("A000000"))
  expect_equal(st_irishgridrefs(x1_sf, precision = 10), c("A00000000"))
  expect_equal(st_irishgridrefs(x1_sf, precision = 1), c("A0000000000"))

  expect_equal(st_irishgridrefs(x2_sf, precision = 100000), c("A", "Z"))
  expect_equal(st_irishgridrefs(x2_sf, precision = 1), c("A0000000000", "Z9000000000"))
})

test_that("only sf", {
  expect_error(st_irishgridrefs(x1_df), class = "not_sf")
})

test_that("only POINT geometry", {
  expect_error(st_irishgridrefs(xe_sf), class = "not_sf_POINT")
})

test_that("invalid precision detected", {
  expect_error(st_irishgridrefs(x1_sf, precision = 0), class = "unsupported_precision")
  expect_error(st_irishgridrefs(x1_sf, precision = 2), class = "unsupported_precision")
  expect_error(st_irishgridrefs(x1_sf, precision = 2000), class = "unsupported_precision")
  expect_error(st_irishgridrefs(x1_sf, precision = "A"), class = "unsupported_precision")
})

test_that("no precision detected", {
  expect_error(st_irishgridrefs(x1_sf, digits = NA, precision = NULL), class = "no_precision")
})