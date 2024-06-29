test_that("basic conversions", {
  # expect_equal(igr_to_ig("A"), c(e=0,n=400000))
  # expect_equal(igr_to_ig("A00"), c(e=0,n=400000))
  # expect_equal(igr_to_ig("A09"), c(e=0,n=490000))
  # 
  # expect_equal(igr_to_ig("Z00"), c(e=400000,n=0))
  # expect_equal(igr_to_ig("Z90"), c(e=490000,n=0))
  # 
  # expect_equal(igr_to_ig(c("A00", "Z90")), c(e1=0,e2=490000,n1=400000, n2=0))
  
})

test_that("catch invalid grid references", {
  
  expect_error(igr_to_ig("A0"), class = "bad_input")
  expect_error(igr_to_ig(c("A00", "B0")), class = "bad_input")
  expect_error(igr_to_ig("I00"), class = "bad_input")
  expect_error(igr_to_ig("Ax0"), class = "bad_input")
  expect_error(igr_to_ig("A0x"), class = "bad_input")
  
})