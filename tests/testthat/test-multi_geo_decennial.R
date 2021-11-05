library(cwi)
library(testthat)

test_that("multi_geo_decennial validates state names and FIPS codes", {
  skip_on_ci()
  expect_error(multi_geo_decennial(table = "P035", state = NULL), "Must supply")
  expect_message(multi_geo_decennial(table = "P035", state = 9), "Converting")
  expect_error(multi_geo_decennial(table = "P035", state = "New Haven"), "valid state name")
})

test_that("multi_geo_decennial validates county names", {
  skip_on_ci()
  expect_warning(multi_geo_decennial(table = "P035", state = "09", counties = c("New Haven County", "Cook County")))
  expect_warning(multi_geo_decennial(table = "P035", state = "09", counties = c("New Haven County", "Cook County")), "Cook")
})

test_that("multi_geo_decennial handles regions", {
  skip_on_ci()
  expect_equal(nrow(multi_geo_decennial("P001", towns = NULL, counties = NULL, regions = cwi::regions[c("Greater New Haven", "Greater Bridgeport")])), 3)
})

test_that("multi_geo_decennial suppresses messages from get_decennial if requested", {
  skip_on_ci()
  expect_silent(multi_geo_decennial(table = "P035", towns = NULL, counties = NULL, verbose = F))
  expect_message(multi_geo_decennial(table = "P035", towns = NULL, counties = NULL, verbose = T))
})

test_that("multi_geo_decennial throws error for invalid table names", {
  # one quickie on travis
  # sets padding
  expect_error(multi_geo_decennial(table = "P35", towns = NULL, counties = NULL), "Did you mean P035")
  expect_error(multi_geo_decennial(table = "R001", towns = NULL, counties = NULL), "R is invalid")
})

test_that("multi_geo_decennial handles tables that don't exist", {
  skip_on_ci()
  expect_silent(multi_geo_decennial(table = "P050", towns = NULL, counties = NULL, verbose = F, year = 2010))
  expect_error(multi_geo_decennial(table = "P052", towns = NULL, counties = NULL, verbose = F, year = 2010), "not available")
})
