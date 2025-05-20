test_that("deprecated functions give warnings", {
    xt <- system.file("extdata/test_xtab2015.xlsx", package = "cwi")

    # first round: 1.12.0
    withr::local_options(lifecycle_verbosity = "warning")
    expect_warning(read_xtabs(xt), "1.12.0")
    expect_warning(read_weights(xt, 2015), "1.12.0")
    suppressWarnings(xtabs <- read_xtabs(xt))
    expect_warning(xtab2df(xtabs, 2015), "1.12.0")

    # second round: 1.12.1
    # removed cws_demo
    lvls <- list(under_50 = c("Ages 18-34", "Ages 35-49"))
    cws_demo <- suppressWarnings(read_xtabs(xt, 2015, process = TRUE))
    cws_demo$weight <- 1
    expect_warning(collapse_n_wt(cws_demo, code:response, .lvls = lvls), "1.12.1")
    expect_warning(sub_nonanswers(cws_demo), "1.12.1")
})
