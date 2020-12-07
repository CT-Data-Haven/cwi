context("Error handling for qwi_industry")
library(cwi)
library(testthat)

test_that("checks for API key", {
  skip_on_ci()
  expect_error(qwi_industry(2016, key = NULL), "API key is required")
  # nchar = 0 if not in .Renviron
  expect_error(qwi_industry(2016, key = ""), "API key is required")
})

test_that("handles years not in API", {
  expect_warning(qwi_industry(1990:2000, industries = "23"), "earlier years are being removed")
  skip_on_ci()
  expect_error(qwi_industry(1990:1994, industries = "23"), "only available")
  # should only return 1996-2000
  expect_equal(nrow(suppressWarnings(qwi_industry(1991:2000, industries = "23", annual = T))), 5)
})

test_that("handles long time periods", {
  skip_on_ci()
  expect_message(qwi_industry(2000:2016, industries = "23", annual = T), "multiple calls")
  expect_equal(nrow(qwi_industry(2000:2016, industries = "23", annual = T)), 17)
})
