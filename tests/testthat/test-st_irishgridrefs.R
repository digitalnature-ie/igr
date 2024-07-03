x1_sf <- sf::st_as_sf(data.frame(x = c(0), y = c(400000)), crs = 29903, coords = c("x", "y"))
x2_sf <- sf::st_as_sf(data.frame(x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))

test_that("basic generations", {
  expect_equal(st_irishgridrefs(x1_sf), c("A000000"))
  expect_equal(st_irishgridrefs(x2_sf), c("A000000", "Z900000"))
})

test_that("all resolutions 100km > 1m", {
  expect_equal(st_irishgridrefs(x1_sf, digits = 0), c("A"))
  expect_equal(st_irishgridrefs(x1_sf, digits = 1), c("A00"))
  expect_equal(st_irishgridrefs(x1_sf, digits = 2), c("A0000"))
  expect_equal(st_irishgridrefs(x1_sf, digits = 3), c("A000000"))
  expect_equal(st_irishgridrefs(x1_sf, digits = 4), c("A00000000"))
  expect_equal(st_irishgridrefs(x1_sf, digits = 5), c("A0000000000"))

  expect_equal(st_irishgridrefs(x2_sf, digits = 0), c("A", "Z"))
  expect_equal(st_irishgridrefs(x2_sf, digits = 5), c("A0000000000", "Z9000000000"))
})
