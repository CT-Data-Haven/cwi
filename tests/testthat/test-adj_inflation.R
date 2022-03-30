library(cwi)
library(testthat)

test_that("adj_inflation checks for API key", {
  wages <- data.frame(year = 2015:2019, wage = 100)
  expect_error(adj_inflation(wages, value = wage, year = year, key = ""))
})

test_that("adj_inflation checks column names", {
  # skip_on_ci() # okay bc it errors before making api call

  wages <- data.frame(year = 2015:2019, wage = 100)
  wage2 <- dplyr::rename(wages, y = year)
  expect_error(adj_inflation(wages, year = year) )
  expect_error(adj_inflation(wages, value = wage))

  skip_on_ci()
  expect_s3_class(adj_inflation(wage2, value = wage, year = y), "data.frame")
})

test_that("adj_inflation correctly calculates adjusted amounts", {
  skip_on_ci()

  df2000 <- adj_inflation(data.frame(year = 2000, amount = 100), value = amount, year = year, base_year = 2016)
  hundred_2000 <- floor(df2000$adj_amount)
  expect_equal(hundred_2000, 139)
})

test_that("adj_inflation handles more than 20 years okay", {
  skip_on_ci()

  wages <- data.frame(year = 1990:2016, wage = 100)
  expect_message(adj_inflation(wages, value = wage, year = year, base_year = 2016))
  expect_equal(nrow(adj_inflation(wages, value = wage, year = year, base_year = 2016)), 27)
})

test_that("adj_inflation handles base_year outside year range", {
  skip_on_ci()

  wages <- data.frame(year = 1990:1999, wage = 100)

  expect_equal(nrow(adj_inflation(wages, value = wage, year = year, base_year = 2016)), 10)
})

test_that("adj_inflation prints table header", {
  skip_on_ci()

  wages <- data.frame(year = 2015:2019, wage = 100)

  expect_message(adj_inflation(wages, wage, year, verbose = TRUE), "-- CPI ")
  expect_silent(dummy <- adj_inflation(wages, wage, year, verbose = FALSE))
})

test_that("adj_inflation handles series", {
  wages <- data.frame(year = 2015:2019, wage = 100)
  expect_error(adj_inflation(wages, year = year, value = wage, series = "xxxx"))

  skip_on_ci()

  expect_s3_class(adj_inflation(wages, year = year, value = wage), "data.frame")
  expect_s3_class(adj_inflation(wages, year = year, value = wage, series = "CUUR0000AA0"), "data.frame")
})
