library(cwi)
library(testthat)

skip("QWI API is down :(")

test_that("qwi_industry handles county defaults", {
  skip_on_ci()
  by_state <- qwi_industry(2018, counties = NULL)
  expect_false("county" %in% names(by_state))
  by_county <- qwi_industry(2018, counties = "009")
  expect_true("county" %in% names(by_county))
  all_county <- qwi_industry(2018, counties = "*")
  expect_equal(length(unique(all_county$county)), 8)
})

test_that("qwi_industry checks for API key", {
  skip_on_ci()
  expect_error(qwi_industry(2016, key = NULL), "API key is required")
  # nchar = 0 if not in .Renviron
  expect_error(qwi_industry(2016, key = ""), "API key is required")
})

test_that("qwi_industry handles years not in API", {
  expect_warning(qwi_industry(1990:2000, industries = "23"), "earlier years are being removed")
  skip_on_ci()
  expect_error(qwi_industry(1990:1994, industries = "23"), "only available")
  # should only return 1996-2000
  expect_equal(nrow(suppressWarnings(qwi_industry(1991:2000, industries = "23", annual = T))), 5)
})

test_that("qwi_industry handles long time periods", {
  skip_on_ci()
  expect_message(qwi_industry(2000:2016, industries = "23", annual = T), "multiple calls")
  expect_equal(nrow(qwi_industry(2000:2016, industries = "23", annual = T)), 17)
})
