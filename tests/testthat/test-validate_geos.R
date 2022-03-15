library(cwi)
library(testthat)

test_that("get_county_fips matches & returns FIPS codes", {
  correct <- c("09001", "09009")
  expect_equal(get_county_fips("09", c("New Haven County", "Fairfield County")), correct)
  expect_equal(get_county_fips("09", c("New Haven", "Fairfield")), correct)
  expect_equal(get_county_fips("09", c("09009", "09001")), correct)
  expect_equal(get_county_fips("09", c("009", "001")), correct)
  expect_equal(get_county_fips("09", c(9, 1)), correct)
  expect_equal(get_county_fips("09", c("09009", "09001", "Fairfield")), correct)
})

test_that("get_county_fips catches mismatched county names", {
  correct <- c("09001", "09009")
  expect_equal(suppressWarnings(get_county_fips("09", c("New Haven County", "Fairfield County", "Cook County"))), correct)
  expect_warning(get_county_fips("09", c("New Haven County", "Fairfield County", "Cook County")))
})
