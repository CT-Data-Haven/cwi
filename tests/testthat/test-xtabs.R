context("Read & reshape crosstabs")
library(cwi)
library(testthat)

test_that("xtabs read correct number of rows", {
  xts <- all_xt(read_xtabs)
  expect_equal(nrow(xts[["2015"]]), 59)
  expect_equal(nrow(xts[["2018"]]), 42)
  expect_equal(nrow(xts[["2020"]]), 16)
})

test_that("read_xtabs removes weighted total rows", {
  found <- all_xt(read_xtabs) %>%
    purrr::map(dplyr::pull, x1) %>%
    purrr::map(stringr::str_detect, "Weighted Total") %>%
    purrr::map(any, na.rm = TRUE)
  expect_false(found[["2015"]])
  expect_false(found[["2018"]])
  expect_false(found[["2020"]])
})

test_that("weights read correct number of rows", {
  wts <- all_xt(read_weights)
  expect_equal(nrow(wts[["2015"]]), 23)
  expect_equal(nrow(wts[["2018"]]), 18)
  expect_equal(nrow(wts[["2020"]]), 29)
})

test_that("allows custom name prefixes", {
  xts <- all_xt(read_xtabs, list(name_prefix = "vv"))
  hdrs <- xts %>% purrr::map(ncol) %>% purrr::map(seq_len) %>% purrr::map(~paste0("vv", .))
  expect_equal(names(xts[["2015"]]), hdrs[["2015"]])
  expect_equal(names(xts[["2018"]]), hdrs[["2018"]])
  expect_equal(names(xts[["2020"]]), hdrs[["2020"]])
})

test_that("read_xtabs successfully passes to xtab2df", {
  xts_no_process <- all_xt(read_xtabs) %>% purrr::map(xtab2df)
  xts_process <- all_xt(read_xtabs, list(process = TRUE))
  expect_equal(xts_no_process[["2015"]], xts_process[["2015"]])
  expect_equal(xts_no_process[["2018"]], xts_process[["2018"]])
  expect_equal(xts_no_process[["2020"]], xts_process[["2020"]])

  xts_no_process_args <- all_xt(read_xtabs, list(name_prefix = "v")) %>% purrr::map(xtab2df, col = v1)
  xts_process_args <- all_xt(read_xtabs, list(name_prefix = "v", process = TRUE))
  expect_equal(xts_no_process_args[["2015"]], xts_process_args[["2015"]])
  expect_equal(xts_no_process_args[["2018"]], xts_process_args[["2018"]])
  expect_equal(xts_no_process_args[["2020"]], xts_process_args[["2020"]])
})

test_that("xtab2df properly matches categories & groups", {
  hdrs1 <- tibble::tibble(
    category = c("Connecticut", "Bridgeport", rep("Gender", 2), rep("Age", 4), rep("Race/Ethnicity", 3), rep("Education", 3), rep("Income", 3), rep("Children in HH", 2)),
    group = c("Connecticut", "Bridgeport", "M", "F", "18-34", "35-49", "50-64", "65+", "White", "Black/Afr Amer", "Hispanic", "High school or less", "Some college or Associate's", "Bachelor's or higher", "<$30K", "$30K-$75K", "$75K+", "No", "Yes")
  )
  hdrs2 <- read_xtabs(demo_xt(2018)) %>%
    xtab2df() %>%
    dplyr::distinct(category, group)
  expect_equal(hdrs1, hdrs2)
})

test_that("xtab2df handles crosstabs without codes e.g. 2020", {
  xt18 <- read_xtabs(demo_xt(2018), year = 2018, process = TRUE)
  xt20 <- read_xtabs(demo_xt(2020), year = 2020, process = TRUE)
  expect_s3_class(xt20, "data.frame")

  expect_true("code" %in% names(xt18))
  expect_false("code" %in% names(xt20))

  expect_false("q_number" %in% names(xt18))
  expect_true("q_number" %in% names(xt20))
})
