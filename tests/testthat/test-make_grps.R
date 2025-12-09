test_that("make_grps gets group names", {
    ages <- c(
        "Under 6 years",
        "Under 6 years",
        "Under 6 years",
        "6 to 11 years",
        "6 to 11 years",
        "6 to 11 years",
        "12 to 17 years",
        "12 to 17 years",
        "12 to 17 years",
        "18 to 24 years",
        "18 to 24 years",
        "18 to 24 years",
        "25 to 34 years",
        "25 to 34 years",
        "25 to 34 years",
        "35 to 44 years",
        "35 to 44 years",
        "35 to 44 years",
        "45 to 54 years",
        "45 to 54 years",
        "45 to 54 years",
        "55 to 64 years",
        "55 to 64 years",
        "55 to 64 years",
        "65 to 74 years",
        "65 to 74 years",
        "65 to 74 years",
        "75 years and over",
        "75 years and over",
        "75 years and over"
    )
    age_list <- list(
        under6 = 1,
        under18 = 1:3,
        ages18_34 = 4:5,
        ages65plus = 9:10
    )

    expect_type(make_grps(ages, age_list), "list")
    expect_equal(
        make_grps(ages, age_list)[[3]],
        c("18 to 24 years", "25 to 34 years")
    )
    expect_named(make_grps(ages, age_list), names(age_list))
})

test_that("make_grps makes groups from positions or values", {
    ages <- c(
        "Under 6 years",
        "Under 6 years",
        "Under 6 years",
        "6 to 11 years",
        "6 to 11 years",
        "6 to 11 years",
        "12 to 17 years",
        "12 to 17 years",
        "12 to 17 years",
        "18 to 24 years",
        "18 to 24 years",
        "18 to 24 years",
        "25 to 34 years",
        "25 to 34 years",
        "25 to 34 years",
        "35 to 44 years",
        "35 to 44 years",
        "35 to 44 years",
        "45 to 54 years",
        "45 to 54 years",
        "45 to 54 years",
        "55 to 64 years",
        "55 to 64 years",
        "55 to 64 years",
        "65 to 74 years",
        "65 to 74 years",
        "65 to 74 years",
        "75 years and over",
        "75 years and over",
        "75 years and over"
    )
    age_list_num <- list(under6 = 1, under18 = 1:3, ages65plus = 9:10)
    age_list_char <- list(
        under6 = "Under 6 years",
        under18 = c("Under 6 years", "6 to 11 years", "12 to 17 years"),
        ages65plus = c("65 to 74 years", "75 years and over")
    )

    expect_equal(make_grps(ages, age_list_num), make_grps(ages, age_list_char))
})

test_that("make_grps checks if strings are in vector", {
    ages <- c(
        "Under 6 years",
        "Under 6 years",
        "Under 6 years",
        "6 to 11 years",
        "6 to 11 years",
        "6 to 11 years",
        "12 to 17 years",
        "12 to 17 years",
        "12 to 17 years",
        "18 to 24 years",
        "18 to 24 years",
        "18 to 24 years",
        "25 to 34 years",
        "25 to 34 years",
        "25 to 34 years",
        "35 to 44 years",
        "35 to 44 years",
        "35 to 44 years",
        "45 to 54 years",
        "45 to 54 years",
        "45 to 54 years",
        "55 to 64 years",
        "55 to 64 years",
        "55 to 64 years",
        "65 to 74 years",
        "65 to 74 years",
        "65 to 74 years",
        "75 years and over",
        "75 years and over",
        "75 years and over"
    )
    age_list_char <- list(
        under5 = "Under 5 years",
        under18 = c("Under 6 years", "6 to 11 years", "12 to 17 years")
    )

    expect_error(make_grps(ages, age_list_char))
})
