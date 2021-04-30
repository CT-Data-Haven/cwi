testthat::context("add_logo returns gg")
library(cwi)
library(testthat)

test_that("url as logo returns ggplot", {
  set.seed(123)
  towns <- regions[["New Haven Inner Ring"]]
  town_df <- dplyr::tibble(name = towns, value = runif(length(towns)))
  p <- ggplot2::ggplot(town_df, ggplot2::aes(x = name, y = value)) +
    ggplot2::geom_col()
  logo <- "https://raw.githubusercontent.com/CT-Data-Haven/cwi/main/inst/extdata/25th_logo.png"
  p_out <- add_logo(p, logo)

  expect_true("gg" %in% class(p_out))
})

test_that("img as logo returns ggplot", {
  set.seed(123)
  towns <- regions[["New Haven Inner Ring"]]
  town_df <- dplyr::tibble(name = towns, value = runif(length(towns)))
  p <- ggplot2::ggplot(town_df, ggplot2::aes(x = name, y = value)) +
    ggplot2::geom_col()
  logo <- system.file("extdata/logo.svg", package = "cwi")
  p_out <- add_logo(p, logo)

  expect_true("gg" %in% class(p_out))
})

test_that("null as logo returns ggplot", {
  set.seed(123)
  towns <- regions[["New Haven Inner Ring"]]
  town_df <- dplyr::tibble(name = towns, value = runif(length(towns)))
  p <- ggplot2::ggplot(town_df, ggplot2::aes(x = name, y = value)) +
    ggplot2::geom_col()
  p_out <- add_logo(p)

  expect_true("gg" %in% class(p_out))
})
