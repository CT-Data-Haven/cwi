testthat::context("Error handling in acs_quick_map")
library(cwi)
library(testthat)

test_that("successful calls return ggplots", {
  set.seed(123)
  town_df <- dplyr::tibble(name = regions$`Greater New Haven`) %>%
    dplyr::mutate(value = stats::runif(nrow(.)))
  # new haven neighborhoods
  hood_df <- dplyr::tibble(name = unique(nhv_tracts$name)[1:10]) %>%
    dplyr::mutate(value = stats::runif(10))
  # new haven tracts
  tract_df <- dplyr::tibble(name = sample(unique(nhv_tracts$geoid), 10)) %>%
    dplyr::mutate(value = stats::runif(10))

  # each successfully return ggplot
  expect_is(acs_quick_map(town_df), "ggplot")
  expect_is(acs_quick_map(hood_df, level = "neighborhood", city = "New Haven"), "ggplot")
  expect_is(acs_quick_map(tract_df, level = "tract"), "ggplot")
})

test_that("invalid levels are caught", {
  set.seed(123)
  hood_df <- dplyr::tibble(name = unique(nhv_tracts$name)[1:10]) %>%
    dplyr::mutate(value = stats::runif(10))

  # handle invalid level
  expect_error(acs_quick_map(hood_df, level = "nhood", city = "New Haven"), "Valid geography")
})

test_that("neighborhoods and city names are matched", {
  set.seed(123)
  hood_df <- dplyr::tibble(name = unique(nhv_tracts$name)[1:10]) %>%
    dplyr::mutate(value = stats::runif(10))

  # if level = neighborhood, must supply city
  expect_error(acs_quick_map(hood_df, level = "neighborhood", city = NULL), "supply a city name")

  # using a city name that doesn't have shapefile associated
  expect_error(acs_quick_map(hood_df, level = "neighborhood", city = "Hamden"), "check the name of your city")

  # using a shapefile that doesn't match data—only match is Downtown
  expect_error(acs_quick_map(hood_df, level = "neighborhood", city = "Bridgeport"), "is nearly empty")
  # using a shapefile with no matches—filter out Downtown
  expect_error(acs_quick_map(hood_df %>%
                               dplyr::filter(name != "Downtown"), level = "neighborhood", city = "Bridgeport"), "is empty")
})
