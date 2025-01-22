library(cwi)
library(testthat)

test_that("separate_acs handles column specifications", {
    df <- readRDS(system.file("test_data/age_df.rds", package = "cwi"))

    expect_equal(names(suppressWarnings(separate_acs(df))), c("geoid", "x1", "x2", "x3"))
    expect_length(suppressWarnings(separate_acs(df)), 4)
    expect_length(suppressWarnings(separate_acs(df, drop_total = TRUE)), 3)
    expect_length(suppressWarnings(separate_acs(df, into = c("total", "sex", "age"))), 4)
    expect_length(suppressWarnings(separate_acs(df, into = c("sex", "age"), drop_total = TRUE)), 3)
    expect_identical(
        suppressWarnings(separate_acs(df, into = c("sex", "age"), drop_total = TRUE)),
        suppressWarnings(separate_acs(df, into = c(NA, "sex", "age")))
    )
})

test_that("separate_acs passes arguments to tidyr::separate", {
    df <- readRDS(system.file("test_data/age_df.rds", package = "cwi"))
    expect_warning(separate_acs(df))
    expect_silent(separate_acs(df, fill = "left"))
    expect_true(any(is.na(suppressWarnings(separate_acs(df, fill = "left"))$x1)))
})
