library(cwi)
library(testthat)

test_that("fix_cogs checks data types", {
  x1 <- c("Capitol COG", "Greater Bridgeport", "Northwest Hills COG")
  x2 <- as.factor(x1)
  x3 <- as.numeric(x2)
  expect_type(fix_cogs(x1), "character")
  expect_s3_class(fix_cogs(x2), "factor")
  expect_error(fix_cogs(x3))
})

test_that("fix_cogs correctly makes replacements", {
  x1 <- c("Capitol COG", "Capitol Region", "New Haven", "Greater Bridgeport", "Greater Bridgeport COG", "Northwest Hills COG")
  cogs <- fix_cogs(x1)
  expect_true("Capitol Region COG" %in% cogs)
  expect_true("New Haven" %in% cogs)
  expect_true("Connecticut Metro COG" %in% cogs)
})
