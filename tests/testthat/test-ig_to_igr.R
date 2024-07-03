x1 <- list(x = 0, y = 400000)
x2 <- list(x = c(0, 490000), y = c(400000, 0))

test_that("basic generations", {
  expect_equal(ig_to_igr(x1), c("A000000"))
  expect_equal(ig_to_igr(x2), c("A000000", "Z900000"))
})

test_that("all resolutions 100km > 1m", {
  expect_equal(ig_to_igr(x1, digits = 0), c("A"))
  expect_equal(ig_to_igr(x1, digits = 1), c("A00"))
  expect_equal(ig_to_igr(x1, digits = 2), c("A0000"))
  expect_equal(ig_to_igr(x1, digits = 3), c("A000000"))
  expect_equal(ig_to_igr(x1, digits = 4), c("A00000000"))
  expect_equal(ig_to_igr(x1, digits = 5), c("A0000000000"))

  expect_equal(ig_to_igr(x2, digits = 0), c("A", "Z"))
  expect_equal(ig_to_igr(x2, digits = 5), c("A0000000000", "Z9000000000"))
})
