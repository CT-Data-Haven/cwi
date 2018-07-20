context("Geographies and messaging in multi_geo_decennial")
library(cwi)
library(testthat)

test_that("state names and FIPS codes are validated", {
  skip_on_travis()
  expect_error(multi_geo_decennial(table = "P035", state = NULL), "Must supply")
  expect_message(multi_geo_decennial(table = "P035", state = 9), "Converting")
  expect_error(multi_geo_decennial(table = "P035", state = "New Haven"), "valid state name")
})

test_that("counties are validated", {
  skip_on_travis()
  expect_warning(multi_geo_decennial(table = "P035", state = "09", counties = c("New Haven County", "Cook County")))
  expect_warning(multi_geo_decennial(table = "P035", state = "09", counties = c("New Haven County", "Cook County")), "Cook")
})

test_that("messages from get_decennial are suppressed if requested", {
  skip_on_travis()
  expect_silent(multi_geo_decennial(table = "P035", towns = NULL, counties = NULL, verbose = F))
  expect_message(multi_geo_decennial(table = "P035", towns = NULL, counties = NULL, verbose = T))
})

test_that("invalid table numbers throw error with formatted number", {
  # one quickie on travis
  expect_error(multi_geo_decennial(table = "P35", towns = NULL, counties = NULL))
})
