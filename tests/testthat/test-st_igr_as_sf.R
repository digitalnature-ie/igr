x1 <- data.frame(igr = c("A"))
x2 <- data.frame(igr = c("A", "Z90"))
x3 <- data.frame(igr = c("A", "Z90"), foo = c("foo_A", "foo_Z90"))
xe <- data.frame(igr = c("A"), x = "1")    # cannot have a column x
xe1 <- data.frame(igr = c("AX"))           # invalid grid reference

x1_sf <- sf::st_polygon(list(cbind(
  c(0, 100000, 100000, 0, 0),
  c(400000, 400000, 500000, 500000, 400000)
))) |>
  sf::st_sfc() |>
  sf::st_as_sf(crs = 29903)
x1_sf$igr[1] <- "A"

# with resolution
x1_res_sf <- x1_sf
x1_res_sf$r123[1] <- 100000


test_that("basic conversions", {
  expect_equal(
    st_igr_as_sf(x1, "igr"),
    sf::st_as_sf(data.frame(igr = c("A"), x = c(0), y = c(400000)), crs = 29903, coords = c("x", "y"))
  )

  expect_equal(
    st_igr_as_sf(x2, "igr"),
    sf::st_as_sf(data.frame(igr = c("A", "Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
  )
})

test_that("igrefs", {
  expect_equal(
    st_igr_as_sf(x3, "igr"),
    sf::st_as_sf(data.frame(igr = c("A", "Z90"), foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
  )
  # test for invalid igr
})

test_that("remove", {
  expect_equal(
    st_igr_as_sf(x3, "igr", remove = FALSE),
    sf::st_as_sf(data.frame(igr = c("A", "Z90"), foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
  )
  expect_equal(
    st_igr_as_sf(x3, "igr", remove = TRUE),
    sf::st_as_sf(data.frame(foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
  )
})

test_that("polygons", {
  # check spatially as expected
  expect_equal(
    sf::st_equals(
      st_igr_as_sf(x1, "igr", polygons = TRUE),
      x1_sf
    )[[1]],
    1
  )
  # check columns retained as expected
  expect_equal(
    sf::st_drop_geometry(st_igr_as_sf(x1, "igr", polygons = TRUE)),
    sf::st_drop_geometry(x1_sf)
  )
  # check resolution column named as expected
  expect_equal(
    sf::st_drop_geometry(st_igr_as_sf(x1, "igr", polygons = TRUE, res = "r123")),
    sf::st_drop_geometry(x1_res_sf)
  )
})

test_that("catch invalid inputs", {
  expect_error(st_igr_as_sf(xe, "igr"), class = "bad_input")
})

test_that("catch invalid grid references", {
  expect_error(st_igr_as_sf(xe1, "igr"), "AX", class = "bad_grid_ref")
  expect_error(st_igr_as_sf(xe1, "igr", res = "r1"),  "AX", class = "bad_grid_ref")
})