library(cwi)
library(testthat)

test_that("calc_shares imports from camiller", {
  df <- gnh_tenure %>%
    dplyr::select(-share) %>%
    dplyr::group_by(level, name) %>%
    calc_shares(group = tenure, denom = "total_hh", digits = 2)
  expect_type(df$share, "double")
})
