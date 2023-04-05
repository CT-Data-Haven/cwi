library(cwi)
library(testthat)

# since there's a function that preps but doesn't make API calls, can use that for testing without doing full calls.
test_that("multi_geo_* validates state names and FIPS codes", {
  expect_error(multi_test(state = NULL), "Must supply")

  expect_message(multi_test(state = 9), "Converting")
  expect_error(multi_test(state = "New Haven"), "valid state name")
  expect_error(multi_test(state = "New Haven", src = "decennial", dataset = "sf1", year = 2010, table = "P001"), "valid state name")
})

test_that("multi_geo_* validates counties by name or FIPS", {
  expect_warning(multi_test(state = "09", counties = c("New Haven County", "Cook County")))
  expect_silent(multi_test(state = "09", counties = "009", verbose = FALSE))
  expect_warning(multi_test(state = "09", counties = c("002")))
})

test_that("multi_geo_* validates tract, block group, and PUMA FIPS codes", {
  expect_message(multi_test(pumas = "all"), "PUMAs")
  expect_message(multi_test(pumas = "all", counties = "New Haven"), "PUMAs in New Haven County")
  expect_warning(multi_test(pumas = c("09001", "09002")))
  expect_message(multi_test(tracts = "all"), "tracts")
  expect_warning(multi_test(tracts = c("09001", "09002")))
  expect_message(multi_test(blockgroups = "all"), "groups")
  expect_warning(multi_test(blockgroups = c("09001", "09002")))
})

test_that("multi_geo_* suppresses messages from get_* if requested", {
  expect_silent(multi_test(verbose = FALSE))
  expect_message(multi_test(verbose = TRUE), "Table B01003: TOTAL POPULATION")
})

test_that("multi_geo_acs handles 1-year surveys", {
  skip_on_ci()

  expect_equal(nrow(multi_geo_acs(table = "B01003", towns = NULL, survey = "acs1", year = 2016, sleep = 2)), 9)
  # API no longer has detail tables for 3-year
  # expect_equal(nrow(multi_geo_acs(table = "B01003", towns = NULL, survey = "acs3", year = 2013)), 9)
})

test_that("multi_geo_* handles tables that don't exist", {
  expect_silent(multi_test(table = "B27010", verbose = FALSE, year = 2016))
  expect_error(multi_test(table = "B27010",  verbose = FALSE, year = 2011), "not available")
  expect_error(multi_test(src = "decennial", table = "P1", year = 2010, dataset = "sf1"))
})

test_that("multi_geo_* handles neighborhood geoids", {
  dummy_nhood_00 <- dplyr::mutate(new_haven_tracts19, geoid = paste0(geoid, "00"))
  dummy_nhood_bg <- dplyr::mutate(new_haven_tracts19, geoid = paste0(geoid, "0"))
  dummy_nhood_nm <- dplyr::rename(new_haven_tracts19, fips = geoid)
  expect_message(multi_test(neighborhoods = new_haven_tracts19), "tracts")
  expect_message(multi_test(neighborhoods = dummy_nhood_00))
  expect_message(multi_test(neighborhoods = dummy_nhood_bg))
  expect_silent(multi_test(neighborhoods = dummy_nhood_nm, nhood_geoid = fips, verbose = FALSE))
})

test_that("multi_geo_* handles neighborhood names", {
  # previously was returning name, name_2 columns
  skip_on_ci()
  acs_df <- multi_geo_acs("B01003", year = 2019, neighborhoods = new_haven_tracts19)
  dec_df <- multi_geo_decennial("P001", year = 2010, neighborhoods = new_haven_tracts19)
  expect_false(any(grepl("\\d", names(acs_df))))
  expect_false(any(grepl("\\d", names(dec_df))))
})

test_that("multi_geo_* handles passing args to tidycensus::get_*", {
  skip_on_ci()
  with_sf <- multi_geo_acs("B01003", geometry = TRUE)
  expect_s3_class(with_sf, "sf")
})

test_that("multi_geo_* handles missing columns", {
  # if no towns are included, there won't be a county column--should be able to deal without error
  skip_on_ci()
  expect_s3_class(multi_geo_acs(table = "B01003", towns = NULL, survey = "acs1", year = 2016, sleep = 2), "data.frame")
})

test_that("multi_geo_* handles New England, other MSAs", {
  # filtering for NE broke because of making names lowercase
  skip_on_ci()
  expect_s3_class(multi_geo_acs(table = "B01003", msa = TRUE, new_england = FALSE), "data.frame")
  expect_s3_class(multi_geo_acs(table = "B01003", msa = TRUE, new_england = TRUE), "data.frame")
})

test_that("multi_geo_* handles MSA label change in 2021", {
  # filtering for NE broke because of making names lowercase
  skip_on_ci()
  expect_s3_class(multi_geo_acs(table = "B01003", msa = TRUE, year = 2020), "data.frame")
  expect_s3_class(multi_geo_acs(table = "B01003", msa = TRUE, year = 2021), "data.frame")
})

test_that("multi_geo_decennial handles sf1, sf3, or pl", {
  skip_on_ci()
  expect_s3_class(multi_geo_decennial(table = "P3", year = 2020, sumfile = "pl"), "data.frame")
})
