test_that("basic conversions", {
  expect_equal(igr_to_ig("A"), list(x = 0, y = 400000))
  expect_equal(igr_to_ig("A1234"), list(x = 12000, y = 434000))
  expect_equal(igr_to_ig("a1234"), list(x = 12000, y = 434000))
  expect_equal(igr_to_ig("A09"), list(x = 0, y = 490000))

  expect_equal(igr_to_ig("Z00"), list(x = 400000, y = 0))
  expect_equal(igr_to_ig("Z90"), list(x = 490000, y = 0))

  expect_equal(igr_to_ig(c("A00", "Z90")), list(x = c(0, 490000), y = c(400000, 0)))

  expect_equal(igr_to_ig(NULL), list(x = double(), y = double()))
  expect_equal(igr_to_ig(c("A00", NULL)), list(x = c(0, double()), y = c(400000, double())))
})

test_that("white space", {
  expect_equal(igr_to_ig(" A 12 34 "), list(x = 12000, y = 434000))
  expect_equal(igr_to_ig("A 12 34"), list(x = 12000, y = 434000))
  expect_equal(igr_to_ig("A12 34"), list(x = 12000, y = 434000))
})

test_that("all precisions 100km > 1m", {
  expect_equal(igr_to_ig("A"), list(x = 000000, y = 400000))
  expect_equal(igr_to_ig("A11"), list(x = 010000, y = 410000))
  expect_equal(igr_to_ig("A1212"), list(x = 012000, y = 412000))
  expect_equal(igr_to_ig("A123123"), list(x = 012300, y = 412300))
  expect_equal(igr_to_ig("A12341234"), list(x = 012340, y = 412340))
  expect_equal(igr_to_ig("A1234512345"), list(x = 012345, y = 412345))

  expect_equal(igr_to_ig(c("A", "B11")), list(x = c(000000, 110000), y = c(400000, 410000)))
  expect_equal(igr_to_ig(c("A11", "B11")), list(x = c(010000, 110000), y = c(410000, 410000)))
  expect_equal(igr_to_ig(c("A1212", "B11")), list(x = c(012000, 110000), y = c(412000, 410000)))
  expect_equal(igr_to_ig(c("A123123", "B11")), list(x = c(012300, 110000), y = c(412300, 410000)))
  expect_equal(igr_to_ig(c("A12341234", "B11")), list(x = c(012340, 110000), y = c(412340, 410000)))
  expect_equal(igr_to_ig(c("A1234512345", "B11")), list(x = c(012345, 110000), y = c(412345, 410000)))
})

test_that("tetrads valid", {
  expect_equal(igr_to_ig("A00A"), list(x = 000000, y = 400000))
  expect_equal(igr_to_ig("A00Z"), list(x = 008000, y = 408000))
  expect_equal(igr_to_ig("Z00Y"), list(x = 408000, y = 006000))
})

test_that("rename coordinates", {
  expect_equal(igr_to_ig("A00", coords = c("x", "y")), list(x = 0, y = 400000))
  expect_equal(igr_to_ig("A00", coords = c("e", "n")), list(e = 0, n = 400000))
  expect_equal(igr_to_ig(c("A00", "Z90"), coords = c("e", "n")), list(e = c(0, 490000), n = c(400000, 0)))
})

test_that("precision", {
  expect_equal(igr_to_ig("A", coords = c("x", "y"), precision = "prec"), list(x = 0, y = 400000, prec = 100000))
  expect_equal(igr_to_ig("A00", coords = c("e", "n"), precision = "p"), list(e = 0, n = 400000, p = 10000))
  expect_equal(igr_to_ig("A 00001 00002", coords = c("e", "n"), precision = "p"), list(e = 1, n = 400002, p = 1))
  expect_equal(igr_to_ig(c("A00", "Z"), coords = c("e", "n"), precision = "pr"), list(e = c(0, 400000), n = c(400000, 0), pr = c(10000, 100000)))
})

test_that("Warning for invalid grid references", {
  expect_warning(igr_to_ig(""))
  expect_warning(igr_to_ig(NA_character_))
  expect_warning(igr_to_ig(2), "2")
  expect_warning(igr_to_ig(c("A", 3), "3"))
  expect_warning(igr_to_ig("A0"), "A0")
  expect_warning(igr_to_ig("A123456123456"), "A123456123456")
  expect_warning(igr_to_ig(c("A00", "B0")), "B0")
  expect_warning(igr_to_ig("I00"), "I00")
  expect_warning(igr_to_ig("Ax0"), "Ax0")
  expect_warning(igr_to_ig("A0x"), "A0x")
  expect_warning(igr_to_ig("AA0"), "AA0")
  expect_warning(igr_to_ig("AA"), "AA")
  expect_warning(igr_to_ig("A 0 0 00"), "A 0 0 00")
  expect_warning(igr_to_ig(c("A", "B", "A0")), "A0")
  expect_warning(igr_to_ig(c("A", "B", "A0", "B1234", "C0")), "A0.*C0")
})

test_that("Warning for invalid tetrad grid references", {
  expect_warning(igr_to_ig("A99A", tetrad=FALSE))
  expect_warning(igr_to_ig("A99O", tetrad=TRUE))
  expect_warning(igr_to_ig("A99O", tetrad=FALSE))
})