context("Error handling for laus_trend")
library(tidyverse)
library(cwi)
library(testthat)

test_that("checks for API key", {
  expect_error(laus_trend("New Haven", 2012, 2016, key = NULL), "API key is required")
  # such as if not set in .Renviron
  expect_error(laus_trend("New Haven", 2012, 2016, key = ""), "API key is required")
})

test_that("checks possible measures & accepts keyword 'all'", {
  expect_error(laus_trend("New Haven", 2012, 2016, measures = "jobs"), "Possible measures are")

  expect_equal(nrow(laus_trend("New Haven", 2016, 2016, measures = "all", annual = F)), 12 * 4)
})

test_that("catches invalid area names", {
  expect_error(laus_trend(c("New Haven", "South Haven"), 2016, 2016), "Limit towns")
})

test_that("handles more than 20 years okay", {
  expect_message(laus_trend("New Haven", 1990, 2016, measures = "employment"), "multiple calls")
  expect_equal(nrow(laus_trend("New Haven", 1990, 2016, measures = "employment")), 27 * 12)
})
