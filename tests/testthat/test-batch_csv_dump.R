library(cwi)

test_that("batch_csv_dump checks input data & split_by", {
    df <- dummy_df()
    split_df <- split(df, df$region)

    expect_error(batch_csv_dump(df, path = tempdir()))
    expect_type(batch_csv_dump(split_df, path = tempdir()), "list")
})

test_that("batch_csv_dump output is same as input", {
    df <- dummy_df()
    df <- df[order(df$region, df$name), ]
    rownames(df) <- NULL
    split_df <- split(df, df$region)

    expect_equal(
        batch_csv_dump(df, split_by = region, path = tempdir(), bind = TRUE),
        df
    )
    expect_equal(batch_csv_dump(split_df, path = tempdir()), split_df)
})

test_that("batch_csv_dump errors missing path", {
    df <- dummy_df()

    expect_error(batch_csv_dump(df, split_by = region, path = "dummy"))
})

test_that("batch_csv_dump prints messages if verbose", {
    df <- dummy_df()

    expect_message(batch_csv_dump(
        df,
        split_by = region,
        path = tempdir(),
        verbose = TRUE
    ))
})

test_that("batch_csv_dump passes arguments to write.csv", {
    # remember batch_csv_dump uses write.csv, not readr::write_csv!
    df <- data.frame(
        region = rep(c("A", "B", "C"), each = 2),
        value = c(NA_real_, runif(5))
    )
    dir <- tempdir()
    set_na <- batch_csv_dump(
        df,
        split_by = region,
        path = dir,
        base_name = "set_na",
        na = ""
    )

    # should have blank at end of line
    set_na_read <- stringr::str_remove_all(
        readLines(file.path(dir, "set_na_A.csv")),
        '\"'
    )
    expect_true(grepl(",$", set_na_read[2]))
    expect_false(grepl(",$", set_na_read[3]))
})
