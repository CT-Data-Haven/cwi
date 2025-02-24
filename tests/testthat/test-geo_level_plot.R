test_that("geo_level_plot checks for valid plot types", {
    df <- data.frame(
        name = letters[1:10],
        value = stats::rnorm(10),
        level = sample(LETTERS[1:3], 10, replace = TRUE)
    )
    expect_s3_class(geo_level_plot(df), "gg")
    expect_s3_class(geo_level_plot(df, dark_gray = "pink"), "gg")
    expect_error(geo_level_plot(df, type = "boxplot"))
})

test_that("geo_level_plot handles tidyeval", {
    df <- data.frame(
        location = letters[1:10],
        pop = stats::rnorm(10),
        geo_lvl = sample(LETTERS[1:3], 10, replace = TRUE)
    )
    expect_s3_class(geo_level_plot(df, name = location, value = pop, level = geo_lvl), "gg")
})
