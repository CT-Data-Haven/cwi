demo_xt <- function(f) {
    system.file("extdata", sprintf("test_xtab%s.xlsx", f), package = "cwi")
}

all_xt <- function(.fun, args = NULL) {
    c(2015, 2018, 2020, 2021) |>
        rlang::set_names() |>
        purrr::map(demo_xt) |>
        purrr::imap(~ R.utils::doCall(.fcn = .fun, path = .x, year = .y, args = args))
}

multi_test <- function(src = "acs",
                       table = "B01003",
                       year = 2021,
                       towns = "all",
                       regions = NULL,
                       counties = "all",
                       state = "09",
                       neighborhoods = NULL,
                       tracts = NULL,
                       blockgroups = NULL,
                       pumas = NULL,
                       msa = FALSE,
                       us = FALSE,
                       new_england = TRUE,
                       nhood_name = "name",
                       nhood_geoid = NULL,
                       dataset = "acs5",
                       verbose = TRUE,
                       key = NULL) {
    multi_geo_prep(src, table, year, towns, regions, counties, state, neighborhoods, tracts, blockgroups, pumas, msa, us, new_england, {{ nhood_name }}, {{ nhood_geoid }}, dataset, verbose, key)
}

bls_test <- function(seasonal = FALSE,
                     year = year,
                     base_year = 2021,
                     verbose = TRUE,
                     key = NULL) {
    series <- get_cpi_series(seasonal = seasonal, TRUE, TRUE)
    yrs <- cpi_yrs(year, base_year)
    query <- cpi_prep(series, yrs, verbose, key)
    return(list(yrs = yrs, query = query))
}


dummy_df <- function(seed = 123, n = 20) {
    set.seed(seed)
    df <- data.frame(
        name = sample(letters, n, replace = FALSE),
        region = sample(LETTERS[1:5], n, replace = TRUE),
        value = stats::rnorm(n)
    )
    df
}
