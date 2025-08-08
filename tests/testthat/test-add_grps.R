test_that("add_grps retains grouping", {
    edu_list <- list(total = 1, less_than_hs = 2:16, bach_plus = 22:25)

    edu1 <- education |>
        dplyr::group_by(name) |>
        add_grps(edu_list, group = edu_level)
    edu2 <- education |>
        add_grps(edu_list, group = edu_level)

    expect_true(dplyr::is_grouped_df(edu1))
    expect_false(dplyr::is_grouped_df(edu2))
})

test_that("add_grps properly creates factor", {
    edu_list <- list(total = 1, less_than_hs = 2:16, bach_plus = 22:25)

    edu1 <- education |>
        dplyr::group_by(name) |>
        add_grps(edu_list, group = edu_level)

    # expect_is(edu1$edu_level, "factor")
    expect_s3_class(edu1$edu_level, "factor")
    expect_equal(levels(edu1$edu_level), names(edu_list))
})

test_that("add_grps retains or drops MOE", {
    edu_list <- list(total = 1, less_than_hs = 2:16, bach_plus = 22:25)

    edu_no_moe <- education |>
        dplyr::group_by(name) |>
        add_grps(edu_list, group = edu_level)
    edu_moe <- education |>
        dplyr::group_by(name) |>
        add_grps(edu_list, group = edu_level, moe = moe)

    expect_equal(ncol(edu_no_moe), 3)
    expect_equal(ncol(edu_moe), 4)
})
