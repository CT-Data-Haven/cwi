test_that("jenks prints warnings", {
  set.seed(1)
  x1 <- rexp(n = 100)
  x2 <- rexp(n = 3)
  x3 <- rep(1:5, each = 5)
  expect_error(jenks(as.factor(letters)))
  expect_error(jenks(x1, n = 1))
  expect_error(jenks(x2, n = 5))
  expect_warning(jenks(x3))
})

test_that("jenks handles labels", {
  set.seed(1)
  x <- rexp(n = 100)
  brk <- jenks(x, n = 5, labels = letters[1:5])
  expect_equal(levels(brk), letters[1:5])
})
