test_that("show_uniq unique values printed", {
    expect_output(gnh_tenure |>
        show_uniq(tenure))
})

test_that("show_uniq returns original data frame", {
    d <- gnh_tenure |>
        dplyr::filter(name == "Branford")
    expect_equal(d, gnh_tenure |>
        dplyr::filter(name == "Branford") |>
        show_uniq(tenure))
})
