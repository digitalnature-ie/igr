x1 <- data.frame(igr = c("A"))
x2 <- data.frame(igr = c("A", "Z90"))
x2t <- data.frame(igr = c("A", "Z90Z"))
x3 <- data.frame(igrefs = c("A", "Z90"), foo = c("foo_A", "foo_Z90"))
xe <- data.frame(igr = c("A"), x = "1") # cannot have a column x
xe1 <- data.frame(igr = c("AX")) # invalid grid reference
xe2 <- data.frame(igr = c("")) # invalid grid reference
xe3 <- data.frame(igr = c(NA_character_)) # invalid grid reference
xe4 <- data.frame(igr = c("A", "")) # valid and invalid grid reference

x1_sf <- sf::st_polygon(list(cbind(
  c(0, 100000, 100000, 0, 0),
  c(400000, 400000, 500000, 500000, 400000)
))) |>
  sf::st_sfc() |>
  sf::st_as_sf(crs = 29903)
x1_sf$igr[1] <- "A"

# with precision
x1_prec_sf <- x1_sf
x1_prec_sf$p123[1] <- 100000


test_that("basic conversions", {
  expect_equal(
    st_igr_as_sf(x1),
    sf::st_as_sf(data.frame(igr = c("A"), x = c(0), y = c(400000)), crs = 29903, coords = c("x", "y"))
  )

  expect_equal(
    st_igr_as_sf(x2),
    sf::st_as_sf(data.frame(igr = c("A", "Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
  )

  expect_equal(
    st_igr_as_sf(x2t),
    sf::st_as_sf(data.frame(igr = c("A", "Z90Z"), x = c(0, 498000), y = c(400000, 8000)), crs = 29903, coords = c("x", "y"))
  )
})

test_that("igrefs", {
  expect_equal(
    st_igr_as_sf(x2, "igr"),
    sf::st_as_sf(data.frame(igr = c("A", "Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
  )
  expect_error(st_igr_as_sf(x2, "wrong"), class = "missing_igrefs")
})

test_that("multiple columns", {
  expect_equal(
    st_igr_as_sf(x3, "igrefs"),
    sf::st_as_sf(data.frame(igrefs = c("A", "Z90"), foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
  )

  expect_equal(
    st_igr_as_sf(x3, 1),
    sf::st_as_sf(data.frame(igrefs = c("A", "Z90"), foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
  )
})

test_that("remove", {
  expect_equal(
    st_igr_as_sf(x3, "igrefs", remove = FALSE),
    sf::st_as_sf(data.frame(igrefs = c("A", "Z90"), foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
  )
  expect_equal(
    st_igr_as_sf(x3, "igrefs", remove = TRUE),
    sf::st_as_sf(data.frame(foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
  )
})

test_that("add_coords", {
  expect_equal(
    st_igr_as_sf(x3, "igrefs", add_coords = FALSE),
    sf::st_as_sf(data.frame(igrefs = c("A", "Z90"), foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"), remove = TRUE)
  )
  expect_equal(
    st_igr_as_sf(x3, "igrefs", add_coords = TRUE),
    sf::st_as_sf(data.frame(igrefs = c("A", "Z90"), foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"), remove = FALSE)
  )
})

test_that("precision", {
  expect_equal(
    st_igr_as_sf(x3, "igrefs"),
    sf::st_as_sf(data.frame(igrefs = c("A", "Z90"), foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0)), crs = 29903, coords = c("x", "y"))
  )
  expect_equal(
    st_igr_as_sf(x3, "igrefs", precision = "p"),
    sf::st_as_sf(data.frame(igrefs = c("A", "Z90"), foo = c("foo_A", "foo_Z90"), x = c(0, 490000), y = c(400000, 0), p = c(100000, 10000)), crs = 29903, coords = c("x", "y"))
  )
})

test_that("polygons", {
  # check spatially as expected
  expect_equal(
    sf::st_equals(
      st_igr_as_sf(x1, polygons = TRUE),
      x1_sf
    )[[1]],
    1
  )
  # check columns retained as expected
  expect_equal(
    sf::st_drop_geometry(st_igr_as_sf(x1, polygons = TRUE)),
    sf::st_drop_geometry(x1_sf)
  )
  # check resolution column named as expected
  expect_equal(
    sf::st_drop_geometry(st_igr_as_sf(x1, polygons = TRUE, precision = "p123")),
    sf::st_drop_geometry(x1_prec_sf)
  )
})

test_that("catch invalid inputs", {
  expect_error(st_igr_as_sf(xe), class = "bad_input")
})

test_that("catch invalid grid references", {
  expect_error(st_igr_as_sf(xe1), "AX", class = "bad_grid_ref")
  expect_error(st_igr_as_sf(xe2), class = "bad_grid_ref")
  expect_error(st_igr_as_sf(xe3), class = "bad_grid_ref")
  expect_error(st_igr_as_sf(xe4), class = "bad_grid_ref")
  expect_error(st_igr_as_sf(xe1, precision = "p1"), "AX", class = "bad_grid_ref")
  expect_error(st_igr_as_sf(x2t, tetrad = FALSE), "Z90Z", class = "bad_grid_ref")
})
