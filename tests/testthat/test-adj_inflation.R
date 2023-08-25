library(cwi)
library(testthat)

test_that("adj_inflation checks for API key", {
  expect_error(bls_test(year = 2011:2014, key = ""))
  expect_type(bls_test(year = 2011:2014, key = NULL), "list")
  expect_type(bls_test(year = 2011:2014, key = Sys.getenv("BLS_KEY")), "list")
  expect_gt(nchar(bls_test(year = 2011:2014)$query[[1]]$body$registrationKey), 0)
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

test_that("adj_inflation handles years okay", {
  short_yrs <- bls_test(year = 2019:2020, base_year = 2021)
  long_yrs <- bls_test(year = 2000:2021, base_year = 2021)
  oob_yrs <- bls_test(year = 2000:2005, base_year = 2021)
  max_yr <- 10
  expect_length(long_yrs$yrs, ceiling(length(2000:2021) / max_yr))
  expect_length(oob_yrs$yrs, ceiling(length(2000:2021) / max_yr))
  expect_equal(short_yrs$query[[1]]$body$endyear, 2021)
})

test_that("adj_inflation prints table header", {
  skip_on_ci()

  wages <- data.frame(year = 2015:2019, wage = 100)

  expect_message(adj_inflation(wages, wage, year, verbose = TRUE), "-- CPI ")
  expect_silent(dummy <- adj_inflation(wages, wage, year, verbose = FALSE))
})

test_that("adj_inflation correctly calculates adjusted amounts", {
  skip_on_ci()

  df2000 <- adj_inflation(data.frame(year = 2000, amount = 100), value = amount, year = year, base_year = 2016)
  hundred_2000 <- floor(df2000$adj_amount)
  expect_equal(hundred_2000, 139)
})
