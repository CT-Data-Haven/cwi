context("Geographies and messaging in multi_geo_acs")
library(cwi)
library(testthat)

test_that("state names and FIPS codes are validated", {
  # only do one quickie on travis
  expect_error(multi_geo_acs(table = "B01003", state = NULL), "Must supply")

  skip_on_ci()
  expect_message(multi_geo_acs(table = "B01003", state = 9), "Converting")
  expect_error(multi_geo_acs(table = "B01003", state = "New Haven"), "valid state name")
})

test_that("counties are validated", {
  skip_on_ci()
  expect_warning(multi_geo_acs(table = "B01003", state = "09", counties = c("New Haven County", "Cook County")))
  expect_warning(multi_geo_acs(table = "B01003", state = "09", counties = c("New Haven County", "Cook County")), "Cook")
})

test_that("messages from get_acs are suppressed if requested", {
  skip_on_ci()
  expect_silent(multi_geo_acs(table = "B01003", towns = NULL, counties = NULL, verbose = F))
  expect_message(multi_geo_acs(table = "B01003", towns = NULL, counties = NULL, verbose = T))
})

test_that("handles 1-year and 3-year surveys", {
  skip_on_ci()
  expect_equal(nrow(multi_geo_acs(table = "B01003", towns = NULL, survey = "acs1", year = 2016)), 9)
  # API no longer has detail tables for 3-year
  # expect_equal(nrow(multi_geo_acs(table = "B01003", towns = NULL, survey = "acs3", year = 2013)), 9)
})

test_that("handles tables that don't exist", {
  skip_on_ci()
  expect_silent(multi_geo_acs(table = "B27010", towns = NULL, counties = NULL, verbose = F, year = 2016))
  expect_error(multi_geo_acs(table = "B27010", towns = NULL, counties = NULL, verbose = F, year = 2011), "not available")
})

test_that("handles neighborhood geoids", {
  skip_on_ci()
  dummy_nhood <- dplyr::mutate(nhv_tracts, geoid = paste0(geoid, "00"))
  expect_message(multi_geo_acs("B01003", neighborhoods = nhv_tracts), "tracts")
  expect_message(multi_geo_acs("B01003", neighborhoods = nhv_bgrps), "block groups")
  expect_message(multi_geo_acs("B01003", neighborhoods = dummy_nhood), "incorrect")
})
