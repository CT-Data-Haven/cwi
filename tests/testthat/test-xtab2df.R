test_that("xtab2df properly matches categories & groups", {
  hdrs1 <- tibble::enframe(list(
    Connecticut = "Connecticut", Bridgeport = "Bridgeport",
    Gender = c("M", "F"),
    Age = c("18-34", "35-49", "50-64", "65+"),
    "Race/Ethnicity" = c("White", "Black/Afr Amer", "Hispanic"),
    Education = c("High school or less", "Some college or Associate's", "Bachelor's or higher"),
    Income = c("<$30K", "$30K-$75K", "$75K+"),
    "Children in HH" = c("No", "Yes")
  ), name = "category", value = "group") %>%
    tidyr::unnest(group)
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
