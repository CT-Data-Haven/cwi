context("Bit of error handling in geo_level_plot")
library(cwi)
library(testthat)

test_that("checks for valid plot types", {
  df <- data.frame(name = letters[1:10],
                   value = rnorm(10),
                   level = sample(LETTERS[1:3], 10, replace = TRUE)
                   )
  expect_is(geo_level_plot(df), "ggplot")
  expect_is(geo_level_plot(df, dark_gray = "pink"), "ggplot")
  expect_error(geo_level_plot(df, type = "boxplot"))
})
