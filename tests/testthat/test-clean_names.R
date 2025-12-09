# mostly used in data-raw functions, ones moved to dcws
# also test availability, multi_geo, qwi
test_that("clean_names checks for data frames", {
    x_df <- data.frame(`New Haven` = letters[1:3], new_haven = letters[4:6])
    x_tb <- dplyr::as_tibble(x_df)
    expect_error(clean_names(names(x_df)))
    cleaned_df <- clean_names(x_df)
    cleaned_tb <- clean_names(x_tb)
    expect_equal(names(cleaned_df), c("new_haven", "new_haven_2"))
    expect_equal(names(cleaned_tb), c("new_haven", "new_haven_2"))
    expect_s3_class(cleaned_df, "data.frame")
})

test_that("make_clean_names makes everything lowercase", {
    x <- c("GEOID", "geoid", "Geoid")
    expect_equal(
        make_clean_names(x, TRUE),
        rep("geoid", length(x))
    )
})

test_that("make_clean_names converts space, punctuation to underscores", {
    x <- c(
        "Greater New Haven",
        "Greater  New   Haven",
        "greater-new-haven",
        "greater.new.haven"
    )
    expect_equal(
        make_clean_names(x, TRUE),
        rep(c("greater_new_haven"), length(x))
    )
})

test_that("make_clean_names cleans leading/trailing digits, punctuation", {
    x <- c("10 geoid", "10geoid", "-geoid", "geoid-")
    expect_equal(
        make_clean_names(x, TRUE),
        c("x10_geoid", "x10geoid", "geoid", "geoid")
    )
})

test_that("make_clean_names makes word breaks from mixed capitalization", {
    x <- c("Prekindergarten", "PreKindergarten")
    expect_equal(
        make_clean_names(x),
        c("prekindergarten", "pre_kindergarten")
    )
})

test_that("make_clean_names deduplicates", {
    x <- c("geoid", "geoid10", "Geoid", "geoid10")
    expect_equal(
        make_clean_names(x),
        c("geoid", "geoid10", "geoid_2", "geoid10_2")
    )
    expect_equal(
        make_clean_names(x, allow_dupes = TRUE),
        c("geoid", "geoid10", "geoid", "geoid10")
    )
})
