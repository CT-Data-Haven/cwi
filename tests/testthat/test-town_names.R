context("town_names cleans town names")
library(cwi)
library(testthat)

test_that("removes 'town, * County' & filters undefined", {
  skip_on_ci()
  pops <- tidycensus::get_acs(geography = "county subdivision", variables = "B01003_001", state = "09", county = "09", key = Sys.getenv("CENSUS_API_KEY"))
  cleaned <- town_names(pops, NAME)
  # removes one observation of County subdivisions undefined
  expect_equal(nrow(cleaned), nrow(pops) - 1)
  expect_false(any(stringr::str_detect(cleaned$NAME, "County")))
})
