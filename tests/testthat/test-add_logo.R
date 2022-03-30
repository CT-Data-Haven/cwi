library(cwi)
library(testthat)

test_that("add_logo with url as logo returns ggplot", {
  set.seed(123)
  towns <- regions[["New Haven Inner Ring"]]
  town_df <- dplyr::tibble(name = towns, value = runif(length(towns)))
  p <- ggplot2::ggplot(town_df, ggplot2::aes(x = name, y = value)) +
    ggplot2::geom_col()
  logo <- "https://raw.githubusercontent.com/CT-Data-Haven/cwi/main/inst/extdata/25th_logo.png"
  p_out <- add_logo(p, logo)

  expect_s3_class(p_out, "gg")
})

test_that("add_logo with img as logo returns ggplot", {
  set.seed(123)
  towns <- regions[["New Haven Inner Ring"]]
  town_df <- dplyr::tibble(name = towns, value = runif(length(towns)))
  p <- ggplot2::ggplot(town_df, ggplot2::aes(x = name, y = value)) +
    ggplot2::geom_col()
  logo <- system.file("extdata/logo.svg", package = "cwi")
  p_out <- add_logo(p, logo)

  expect_s3_class(p_out, "gg")
})

test_that("add_logo with null as logo returns ggplot", {
  set.seed(123)
  towns <- regions[["New Haven Inner Ring"]]
  town_df <- dplyr::tibble(name = towns, value = runif(length(towns)))
  p <- ggplot2::ggplot(town_df, ggplot2::aes(x = name, y = value)) +
    ggplot2::geom_col()
  p_out <- add_logo(p)

  expect_s3_class(p_out, "gg")
})
