library(cwi)
library(testthat)

test_that("collapse_n_wt returns correct number of rows", {
  income_lvls <- list("<$30K" = c("<$15K", "$15K-$30K"),
                      "$30K-$100K" = c("$30K-$50K", "$50K-$75K", "$75K-$100K"),
                      "$100K+" = c("$100K-$200K", "$200K+"))
  collapsed <- collapse_n_wt(cws_demo, code:response, .lvls = income_lvls)
  # 4 responses, income_lvls should drop 4 group values
  n <- nrow(cws_demo) - 4L * 4L
  expect_identical(nrow(collapsed), n)
})

test_that("collapse_n_wt handles filling in missing weights", {
  income_lvls <- list("<$30K" = c("<$15K", "$15K-$30K"),
                      "$30K-$100K" = c("$30K-$50K", "$50K-$75K", "$75K-$100K"),
                      "$100K+" = c("$100K-$200K", "$200K+"))
  cws_missing <- cws_demo %>%
    dplyr::mutate(weight = ifelse(category %in% c("Connecticut", "Greater New Haven"), NA_real_, weight))
  expect_message(collapse_n_wt(cws_missing, code:response, .lvls = income_lvls, .fill_wts = TRUE))
  expect_equal(collapse_n_wt(cws_missing, code:response, .lvls = income_lvls, .fill_wts = TRUE),
               collapse_n_wt(cws_demo,    code:response, .lvls = income_lvls, .fill_wts = FALSE))
})
