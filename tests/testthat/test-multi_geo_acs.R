context("Geographies and messaging in multi_geo_acs")
library(cwi)
library(testthat)
library(dplyr)

test_that("state names and FIPS codes are validated", {
  expect_error(multi_geo_acs(table = "B01003", state = NULL), "Must supply")
  expect_message(multi_geo_acs(table = "B01003", state = 9), "Converting")
  expect_error(multi_geo_acs(table = "B01003", state = "New Haven"), "valid state name")
})

test_that("counties are validated", {
  expect_warning(multi_geo_acs(table = "B01003", state = "09", counties = c("New Haven County", "Cook County")))
  expect_warning(multi_geo_acs(table = "B01003", state = "09", counties = c("New Haven County", "Cook County")), "Cook")
})

test_that("messages from get_acs are suppressed if requested", {
  expect_silent(multi_geo_acs(table = "B01003", towns = NULL, counties = NULL, verbose = F))
  expect_message(multi_geo_acs(table = "B01003", towns = NULL, counties = NULL, verbose = T))
})
