library(cwi)
library(testthat)

test_that("laus_trend checks for API key", {
  expect_error(laus_trend("New Haven", 2012, 2016, key = ""))

  skip_on_ci()
  expect_s3_class(laus_trend("New Haven", 2012, 2016, key = NULL), "data.frame")
})

test_that("laus_trend checks possible measures & accepts keyword 'all'", {
  skip_on_ci()

  expect_error(laus_trend("New Haven", 2012, 2016, measures = "jobs"))

  laus <- laus_trend("New Haven", 2016, 2016, measures = "all", annual = FALSE)
  expect_true(all(c("unemployment_rate", "unemployment", "employment", "labor_force") %in% names(laus)))
})

test_that("laus_trend validates geographies", {
  # invalid state
  expect_error(laus_trend("New Haven", 2015, 2016, state = "XX"))

  skip_on_ci()
  # invalid location--warn
  expect_warning(laus_trend(c("New Haven", "South Haven"), 2016, 2016))
  # null location
  ct_locs <- laus_codes |> dplyr::filter(state_code == "09") |> nrow()
  ct_null <- laus_trend(names = NULL, 2016, 2016, state = "09")
  expect_equal(dplyr::n_distinct(ct_null$area), ct_locs)
  # state as abbr / name
  expect_s3_class(laus_trend(names = "New Haven", 2016, 2016, state = "CT"), "data.frame")
  expect_s3_class(laus_trend(names = "New Haven", 2016, 2016, state = "Connecticut"), "data.frame")
})

test_that("laus_trend handles more than 20 years okay", {
  skip_on_ci()
  expect_message(laus <- laus_trend("New Haven", 1990, 2016, measures = "employment", annual = FALSE), "multiple calls")
  expect_equal(nrow(laus), 27 * 12)
})

test_that("laus_trend prints table header", {
  skip_on_ci()

  expect_message(laus_trend("New Haven", 2010, 2015, measures = "employment"), "-- Local Area ")
  expect_silent(dummy <- laus_trend("New Haven", 2010, 2015, measures = "employment", verbose = FALSE))
})

test_that("laus_trend handles annual vs monthly data", {
  skip_on_ci()

  monthly <- laus_trend("New Haven", 2016, 2016, annual = FALSE)
  annual <- laus_trend("New Haven", 2016, 2016, annual = TRUE)
  expect_equal(nrow(monthly), 12)
  expect_equal(nrow(annual), 13)
  expect_true("Annual" %in% annual$periodName)
  expect_false("Annual" %in% monthly$periodName)
})

test_that("laus_trend handles more than 50 series", {
  skip_on_ci()

  srs <- laus_codes |> dplyr::filter(state_code == "09")
  laus <- laus_trend(names = NULL, 2015, 2015, measures = "employment", annual = FALSE)
  expect_equal(nrow(laus), nrow(srs) * 12)
})
