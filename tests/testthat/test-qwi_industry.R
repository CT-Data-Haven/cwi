test_that("qwi_industry handles county defaults", {
    skip_on_ci()
    by_state <- qwi_industry(2018, counties = NULL)
    expect_false("county" %in% names(by_state))
    by_cog <- qwi_industry(2018, counties = "170")
    expect_true("county" %in% names(by_cog))
    all_county <- qwi_industry(2018, counties = "all")
    expect_equal(length(unique(all_county$county)), length(unique(cwi::xwalk$cog)))
})

test_that("qwi_industry handles errors, including from COG mismatches", {
    # error if using counties instead of cogs
    expect_error(qwi_industry(2024, state = "09", counties = "009"), "replaced counties with COGs")
    expect_error(qwi_industry(2099, retry = 1), "only available from")
    expect_error(qwi_industry(2024, industries = "31"), "empty")
})

test_that("qwi_industry checks for API key", {
    expect_error(qwi_industry(2016, key = ""))

    skip_on_ci()
    expect_s3_class(qwi_industry(2016, key = NULL), "data.frame")
    expect_error(qwi_industry(2020, key = "xyz"), "An error occurred")
})

test_that("qwi_industry handles years not in API", {
    expect_warning(qwi_industry(1990:2000, industries = "23"))
    skip_on_ci()
    expect_error(qwi_industry(1990:1994, industries = "23"), "only available")
    # should only return 1996-2000
    expect_equal(nrow(suppressWarnings(qwi_industry(1991:2000, industries = "23", annual = TRUE))), 5)
})

test_that("qwi_industry handles long time periods", {
    skip_on_ci()
    expect_message(qwi_industry(2000:2016, industries = "23", annual = TRUE), "multiple calls")
    expect_equal(nrow(qwi_industry(2000:2016, industries = "23", annual = TRUE)), 17)
})

test_that("qwi_industry handles annual vs quarterly", {
    annual <- qwi_industry(2012, "00", annual = TRUE)
    quarterly <- qwi_industry(2012, "00", annual = FALSE)
    # if annual, summarized to 1 row per year
    expect_equal(nrow(annual), 1)

    # if not annual, unsummarized (4 per year)
    expect_equal(nrow(quarterly), 4)

    # if not annual, make a date
    expect_s3_class(quarterly$date, "Date")
})
