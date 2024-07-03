x1 <- data.frame(igr = c("A"))
x2 <- data.frame(igr = c("A", "Z90"))
x3 <- data.frame(igr = c("A", "Z90"), foo = c("foo_A", "foo_Z90"))

test_that("basic conversions", {
  expect_equal(st_igr_as_sf(x1, "igr"), sf::st_as_sf(data.frame(igr = c("A"), x = c(0), y = c(400000)), crs = 29903, coords = c("x", "y")))

  expect_equal(st_igr_as_sf(x2, "igr"), sf::st_as_sf(data.frame(igr = c("A", "Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y")))
})

test_that("igrefs", {
  expect_equal(st_igr_as_sf(x3, "igr"), sf::st_as_sf(data.frame(igr = c("A", "Z90"), foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y")))
  # test for invalid igr
})

# TODO Add more tests
