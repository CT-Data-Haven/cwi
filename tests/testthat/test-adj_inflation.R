library(cwi)
library(testthat)

test_that("bls functions check for API key", {
    expect_error(bls_test(year = 2011:2014, key = ""))
    expect_type(bls_test(year = 2011:2014, key = NULL), "list")
    expect_type(bls_test(year = 2011:2014, key = Sys.getenv("BLS_KEY")), "list")
    expect_gt(nchar(bls_test(year = 2011:2014)$query[[1]]$body$registrationKey), 0)
})

test_that("adj_inflation checks column names", {
    # skip_on_ci() # okay bc it errors before making api call
    wages <- data.frame(year = 2015:2019, wage = 100)
    wage2 <- dplyr::rename(wages, y = year)
    expect_error(adj_inflation(wages, year = year))
    expect_error(adj_inflation(wages, value = wage))

    skip_on_ci()
    expect_s3_class(adj_inflation(wage2, value = wage, year = y), "data.frame")
})

test_that("adj_inflation handles years okay", {
    short_yrs <- bls_test(year = 2019:2020, base_year = 2021)
    long_yrs <- bls_test(year = 2000:2021, base_year = 2021)
    oob_yrs <- bls_test(year = 2000:2005, base_year = 2021)
    max_yr <- 10
    expect_length(long_yrs$yrs, ceiling(length(2000:2021) / max_yr))
    expect_length(oob_yrs$yrs, ceiling(length(2000:2021) / max_yr))
    expect_equal(short_yrs$query[[1]]$body$endyear, 2021)
})

test_that("inflation functions print table header", {
    skip_on_ci()

    wages <- data.frame(year = 2015:2019, wage = 100)

    expect_message(adj_inflation(wages, wage, year, verbose = TRUE)) # don't directly check text bc API changes
    expect_silent(dummy <- adj_inflation(wages, wage, year, verbose = FALSE))
    expect_message(get_cpi(wages$year, verbose = TRUE))
    expect_silent(dummy <- get_cpi(wages$year, verbose = FALSE))
})

test_that("adj_inflation correctly calculates adjusted amounts", {
    skip_on_ci()

    df2000 <- adj_inflation(data.frame(year = 2000, amount = 100), value = amount, year = year, base_year = 2016)
    hundred_2000 <- floor(df2000$adj_amount)
    expect_equal(hundred_2000, 139)
})

test_that("get_cpi matches series ID with seasonality", {
    # test series number matches seasonal arg
    yrs <- 2010:2014
    base <- 2015
    seas <- bls_test(seasonal = TRUE, year = yrs)[["query"]][[1]][["body"]][["seriesid"]]
    unseas <- bls_test(seasonal = FALSE, year = yrs)[["query"]][[1]][["body"]][["seriesid"]]
    expect_true(grepl("^CUSR", seas))
    expect_true(grepl("^CUUR", unseas))
})

test_that("get_cpi gets correct data type for date/year depending on monthly arg", {
    skip_on_ci()
    yrs <- 2010:2014
    date1 <- get_cpi(yrs, seasonal = TRUE, monthly = TRUE, verbose = FALSE)
    date2 <- get_cpi(yrs, seasonal = FALSE, monthly = TRUE, verbose = FALSE)

    numb1 <- get_cpi(yrs, seasonal = TRUE, monthly = FALSE, verbose = FALSE)
    numb2 <- get_cpi(yrs, seasonal = FALSE, monthly = FALSE, verbose = FALSE)

    expect_true("date" %in% names(date1))
    expect_true("date" %in% names(numb1))

    expect_s3_class(date1$date, "Date")
    expect_s3_class(date2$date, "Date")
    expect_type(numb1$date, "double")
    expect_type(numb2$date, "double")
})
