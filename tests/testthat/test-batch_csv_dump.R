context("Error handling in batch_csv_dump")
library(cwi)
library(testthat)

test_that("checks input data & split_by", {
  set.seed(123)
  df <- data.frame(
    name = sample(letters, 20, replace = F),
    region = sample(LETTERS[1:5], 20, replace = T),
    value = rnorm(20)
  )
  split_df <- split(df, df$region)

  expect_error(batch_csv_dump(df, path = tempdir()), "supply either a list of data frames")
  expect_is(batch_csv_dump(split_df, path = tempdir()), "list")
})

test_that("output is same as input", {
  set.seed(123)
  df <- data.frame(
    name = sample(letters, 20, replace = F),
    region = sample(LETTERS[1:5], 20, replace = T),
    value = rnorm(20)
  )
  df <- df[order(df$region, df$name), ]
  rownames(df) <- NULL
  split_df <- split(df, df$region)

  expect_equal(batch_csv_dump(df, split_by = region, path = tempdir(), bind = TRUE), df)
  expect_equal(batch_csv_dump(split_df, path = tempdir()), split_df)
})

test_that("warns of missing path", {
  set.seed(123)
  df <- data.frame(
    name = sample(letters, 20, replace = F),
    region = sample(LETTERS[1:5], 20, replace = T),
    value = rnorm(20)
  )

  expect_warning(batch_csv_dump(df, split_by = region, path = "dummy"), "does not exist")
})

test_that("prints messages if verbose", {
  set.seed(123)
  df <- data.frame(
    name = sample(letters, 20, replace = F),
    region = sample(LETTERS[1:5], 20, replace = T),
    value = rnorm(20)
  )

  expect_message(batch_csv_dump(df, split_by = region, path = tempdir(), verbose = T), "Writing")
})
