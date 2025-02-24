library(cwi)
library(testthat)

test_that("get_county_fips matches & returns FIPS codes", {
    correct <- c("09001", "09009")
    expect_equal(get_county_fips("09", c("New Haven County", "Fairfield County"), FALSE), correct)
    expect_equal(get_county_fips("09", c("New Haven", "Fairfield"), FALSE), correct)
    expect_equal(get_county_fips("09", c("09009", "09001"), FALSE), correct)
    expect_equal(get_county_fips("09", c("009", "001"), FALSE), correct)
    expect_equal(get_county_fips("09", c(9, 1), FALSE), correct)
    expect_equal(get_county_fips("09", c("09009", "09001", "Fairfield"), FALSE), correct)

    correct_cog <- c("09120", "09190")
    expect_equal(get_county_fips("09", c("Western Connecticut COG", "Greater Bridgeport COG"), TRUE), correct_cog)
    expect_equal(get_county_fips("09", c("120", "190"), TRUE), correct_cog)
})

test_that("get_county_fips catches mismatched county names", {
    correct <- c("09001", "09009")
    expect_equal(suppressWarnings(get_county_fips("09", c("New Haven County", "Fairfield County", "Cook County"), FALSE)), correct)
    expect_warning(get_county_fips("09", c("New Haven County", "Fairfield County", "Cook County"), FALSE))
})

test_that("get_county_fips handles county vs cog fips", {
    cog_all <- get_county_fips("09", "all", TRUE)
    county_all <- get_county_fips("09", "all", FALSE)
    expect_length(cog_all, 9)
    expect_length(county_all, 8)
})

test_that("get_state_fips matches & returns FIPS codes", {
    correct <- "09"
    expect_equal(get_state_fips(9), correct)
    expect_equal(get_state_fips("09"), correct)
    expect_equal(get_state_fips("9"), correct)
    expect_equal(get_state_fips("CT"), correct)
    expect_equal(get_state_fips("Connecticut"), correct)
})
