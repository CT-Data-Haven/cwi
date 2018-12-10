context("Error handling for adj_inflation")
library(cwi)
library(testthat)

test_that("checks for required columns", {
  skip_on_travis()
  skip_on_appveyor()
  wages <- data.frame(
      year = 2010:2016,
      wage = c(50000, 51000, 52000, 53000, 54000, 55000, 54000)
  )
  expect_error(adj_inflation(wages, year = year), "are required")
  expect_error(adj_inflation(wages, value = wage), "are required")
})

test_that("adjusted amounts are calculated correctly", {
  skip_on_travis()
  skip_on_appveyor()
  df2000 <- adj_inflation(data.frame(year = 2000, amount = 100), value = amount, year = year, base_year = 2016)
  hundred_2000 <- floor(df2000$adj_amount)
  expect_equal(hundred_2000, 139)
})

test_that("handles more than 20 years okay", {
  skip_on_travis()
  skip_on_appveyor()
  wages <- data.frame(year = 1990:2016, wage = 100)
  expect_message(adj_inflation(wages, value = wage, year = year, base_year = 2016))
  expect_equal(nrow(adj_inflation(wages, value = wage, year = year, base_year = 2016)), 27)
})

test_that("handles base_year outside year range", {
  skip_on_travis()
  skip_on_appveyor()
  wages <- data.frame(year = 1990:1999, wage = 100)

  expect_equal(nrow(adj_inflation(wages, value = wage, year = year, base_year = 2016)), 10)
})
