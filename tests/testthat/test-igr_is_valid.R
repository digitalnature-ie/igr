test_that("basic valid", {
  expect_equal(igr_is_valid("A"), TRUE)
  expect_equal(igr_is_valid(c("B", "B16", "B1267", "B123678", "B12346789", "B1234567890")), rep(TRUE, 6))
  expect_equal(igr_is_valid(c("A1234", "a1234", " A1234", "A 1234", "A 12 34", "A1234 ")), rep(TRUE, 6))
})

test_that("basic invalid", {
  expect_equal(igr_is_valid("I"), FALSE)
  expect_equal(igr_is_valid(c("", "B1", "B126", "B12367", "B1234678", "B123456789", "B12345167890", "B123451678906")), rep(FALSE, 8))
  expect_equal(igr_is_valid(c("A1 234", "a123 4", "A1 2 34", "A 12 3 4", "A 123 4")), rep(FALSE, 5))
  expect_equal(igr_is_valid(c("AA 1 2", "A1A2", "A12A")), rep(FALSE, 3))
})

test_that("edge invalid", {
  expect_equal(igr_is_valid(""), FALSE)
  expect_equal(igr_is_valid(NULL), NULL)
  expect_equal(igr_is_valid(c("A", NULL, "F")), c(TRUE, NULL, TRUE))
  expect_equal(igr_is_valid(c("A", NA_character_)), c(TRUE, FALSE))
  expect_equal(igr_is_valid(NA_character_), FALSE)
})

test_that("mix", {
  expect_equal(igr_is_valid(c("A", "I")), c(TRUE, FALSE))
  expect_equal(igr_is_valid(c("A12", "A123", "A1256", "A1 256", "A12346789", "")), rep(c(TRUE, FALSE), 3))
})
