library(cwi)
library(testthat)

test_that("batch_csv_dump checks input data & split_by", {
  set.seed(123)
  df <- data.frame(
    name = sample(letters, 20, replace = FALSE),
    region = sample(LETTERS[1:5], 20, replace = TRUE),
    value = rnorm(20)
  )
  split_df <- split(df, df$region)

  expect_error(batch_csv_dump(df, path = tempdir()))
  expect_type(batch_csv_dump(split_df, path = tempdir()), "list")
})

test_that("batch_csv_dump output is same as input", {
  set.seed(123)
  df <- data.frame(
    name = sample(letters, 20, replace = FALSE),
    region = sample(LETTERS[1:5], 20, replace = TRUE),
    value = rnorm(20)
  )
  df <- df[order(df$region, df$name), ]
  rownames(df) <- NULL
  split_df <- split(df, df$region)

  expect_equal(batch_csv_dump(df, split_by = region, path = tempdir(), bind = TRUE), df)
  expect_equal(batch_csv_dump(split_df, path = tempdir()), split_df)
})

test_that("batch_csv_dump warns of missing path", {
  set.seed(123)
  df <- data.frame(
    name = sample(letters, 20, replace = FALSE),
    region = sample(LETTERS[1:5], 20, replace = TRUE),
    value = rnorm(20)
  )

  # will write to working directory, so delete files after
  fns <- paste(LETTERS[1:5], "csv", sep = ".")
  expect_warning(batch_csv_dump(df, split_by = region, path = "dummy"))
  on.exit(purrr::walk(fns, file.remove), add = TRUE)
})

test_that("batch_csv_dump prints messages if verbose", {
  set.seed(123)
  df <- data.frame(
    name = sample(letters, 20, replace = FALSE),
    region = sample(LETTERS[1:5], 20, replace = TRUE),
    value = rnorm(20)
  )

  expect_message(batch_csv_dump(df, split_by = region, path = tempdir(), verbose = TRUE))
})
