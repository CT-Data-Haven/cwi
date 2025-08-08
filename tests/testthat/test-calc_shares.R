test_that("calc_shares retains grouping", {
    tenure_tmp <- gnh_tenure[, 1:4]
    tenure_grp <- tenure_tmp |>
        dplyr::group_by(level, name) |>
        calc_shares(group = tenure, denom = "total_hh")
    tenure_ungrp <- tenure_tmp |>
        calc_shares(level, name, group = tenure, denom = "total_hh")

    expect_true(dplyr::is_grouped_df(tenure_grp))
    expect_false(dplyr::is_grouped_df(tenure_ungrp))
})

test_that("calc_shares handles null moe", {
    edu_est <- edu_brk |>
        dplyr::select(-moe) |>
        calc_shares(name, group = edu_level, denom = "ages25plus")
    edu_moe <- edu_brk |>
        calc_shares(name, group = edu_level, denom = "ages25plus", moe = moe)
    expect_equal(edu_est$share, edu_moe$share)
})

test_that("calc_shares handles ... and group_by", {
    edu1 <- edu_brk |>
        dplyr::group_by(region, name) |>
        calc_shares(group = edu_level, denom = "ages25plus", moe = moe)
    edu2 <- edu_brk |>
        calc_shares(region, name, group = edu_level, denom = "ages25plus", moe = moe)
    edu3 <- edu_brk |>
        dplyr::group_by(region) |>
        calc_shares(name, group = edu_level, denom = "ages25plus", moe = moe)

    expect_setequal(edu2$share, edu1$share)
    expect_setequal(edu3$share, edu1$share)
})

test_that("calc_shares returns 1 NA share per name", {
    edu <- edu_brk |>
        dplyr::group_by(region, name) |>
        calc_shares(group = edu_level, denom = "ages25plus", moe = moe)
    n_names <- length(unique(edu$name))
    expect_length(edu$name[is.na(edu$share)], n_names)
})

test_that("calc_shares checks for denominator in grouping variable", {
    expect_silent(calc_shares(edu_brk, name, group = edu_level, denom = "ages25plus"))
    expect_error(calc_shares(edu_brk, name, group = edu_level, denom = "adults"))
    expect_error(calc_shares(edu_brk, name, group = edu_level))
})
