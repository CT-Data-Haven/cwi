context("Geographies and messaging in multi_geo_acs")
library(cwi)
library(testthat)

test_that("state names and FIPS codes are validated", {
  # only do one quickie on travis
  expect_error(multi_geo_acs(table = "B01003", state = NULL), "Must supply")

  skip_on_travis()
  expect_message(multi_geo_acs(table = "B01003", state = 9), "Converting")
  expect_error(multi_geo_acs(table = "B01003", state = "New Haven"), "valid state name")
})

test_that("counties are validated", {
  skip_on_travis()
  expect_warning(multi_geo_acs(table = "B01003", state = "09", counties = c("New Haven County", "Cook County")))
  expect_warning(multi_geo_acs(table = "B01003", state = "09", counties = c("New Haven County", "Cook County")), "Cook")
})

test_that("messages from get_acs are suppressed if requested", {
  skip_on_travis()
  expect_silent(multi_geo_acs(table = "B01003", towns = NULL, counties = NULL, verbose = F))
  expect_message(multi_geo_acs(table = "B01003", towns = NULL, counties = NULL, verbose = T))
})
