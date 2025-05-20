#' Calculate inflation adjustments
#'
#' `adj_inflation` is modeled after `blscrapeR::inflation_adjust` that joins a data frame with an inflation adjustment table from the Bureau of Labor Statistics' Consumer Price Index, then calculates adjusted values. It returns the original data frame with two additional columns for adjustment factors and adjustment values. `get_cpi` is a more basic version of `adj_inflation`. It doesn't adjust your data for you, just fetches the CPI table used for those adjustments. It handles a couple options: either seasonally-adjusted or unadjusted, and either annual averages or monthly values. `adj_inflation`, by contrast, is fixed to annual and not seasonally adjusted. While `adj_inflation` is a high-level convenience function, `get_cpi` is better suited to doing more complex adjustments yourself, such as setting seasonality or periodicity.
#'
#' **Note:** Because these functions make API calls, internet access is required.
#'
#' According to the BLS research page, the series these functions use are best suited to data going back to about 2000, when their methodology changed. For previous years, a more accurate version of the index is available on their [site](https://www.bls.gov/cpi/research-series/r-cpi-u-rs-home.htm).
#'
#' @param data A data frame containing monetary values by year.
#' @param value Bare column name of monetary values; for safety, has no default.
#' @param year Bare column name of years; for safety, has no default.
#' @param base_year Year on which to base inflation amounts. Defaults to `r cwi:::endyears[["acs"]]`, which corresponds to saying "... adjusted to `r cwi:::endyears[["acs"]]` dollars."
#' @param verbose Logical: if `TRUE` (default), this will print overview information about the series being used, as returned by the API.
#' @param key A string giving the BLS API key. If `NULL` (the default), will take the value in `Sys.getenv("BLS_KEY")`.
#' @return For `adj_inflation`: The original data frame with two additional columns: adjustment factors, and adjusted values. The adjusted values column is named based on the name supplied as `value`; e.g. if `value = avg_wage`, the adjusted column is named `adj_avg_wage`.
#' @examples
#' \dontrun{
#' wages <- data.frame(
#'     fiscal_year = 2010:2016,
#'     wage = c(50000, 51000, 52000, 53000, 54000, 55000, 54000)
#' )
#' adj_inflation(wages, value = wage, year = fiscal_year, base_year = 2016)
#' }
#' @source Bureau of Labor Statistics via their API \url{https://www.bls.gov/developers/home.htm}
#' @rdname inflation
#' @keywords augmenting-functions
#' @export
adj_inflation <- function(data,
                          value,
                          year,
                          base_year = endyears[["acs"]],
                          verbose = TRUE,
                          key = NULL) {
    if (missing(value) || missing(year)) {
        cli::cli_abort("Must supply column names for both value and year.")
    }
    yr_lbl <- rlang::as_label(rlang::enquo(year))
    cpi <- get_cpi(
        years = data[[yr_lbl]],
        base = base_year,
        seasonal = FALSE,
        monthly = FALSE,
        verbose = verbose,
        key = key
    )
    cpi <- dplyr::select(cpi, year = date, adj_factor)

    adjusted <- dplyr::mutate(data, dplyr::across({{ year }}, as.numeric))
    adjusted <- dplyr::left_join(adjusted, cpi, by = stats::setNames("year", yr_lbl))
    adjusted <- dplyr::mutate(adjusted, dplyr::across({{ value }},
        list(adj = \(x) x / adj_factor),
        .names = "{.fn}_{.col}"
    ))
    adjusted
}

#' @param years Numeric vector: years of CPI values to get
#' @param base Base reference point, either a year or a date, or something that can be easily coerced to a date. If just a year, will default to January 1 of that year. Default: `r endyears[["acs"]]`
#' @param seasonal Logical, whether to get seasonally-adjusted or unadjusted values. Default: FALSE
#' @param monthly Logical. If TRUE, return monthly values. Otherwise, CPI values are averaged by the year. Default: FALSE
#' @return For `get_cpi`: A data frame/tibble with columns for date (either numeric years or proper Date objects), CPI value, and adjustment factor based on the `base` argument.
#' @examples
#' \dontrun{
#' get_cpi(2018:2024, base = 2024, monthly = FALSE)
#' get_cpi(2018:2024, base = "2024-12-01", monthly = TRUE)
#' }
#' @keywords augmenting-functions
#' @export
#' @rdname inflation
get_cpi <- function(years,
                    base = endyears[["acs"]],
                    seasonal = FALSE,
                    monthly = FALSE,
                    verbose = TRUE,
                    key = NULL) {
    # either use monthly with base that can be coerced to date, or use annual
    if (monthly) {
        if (!inherits(base, "Date")) {
            # if just year, set to jan 1 of that year
            if (inherits(base, "numeric") | grepl("^\\d{4}$", base)) {
                base <- paste(base, "01", "01", sep = "-")
            }
            base <- as.Date(as.character(base), optional = TRUE)
        }
        # make sure date is the 1st so it can be found in cpi data
        # don't want to add dependencies to get yearmonth class
        base <- format(base, "%Y-%m")
        base <- paste(base, "01", sep = "-")
        base <- as.Date(base, optional = TRUE)
        if (any(is.na(base))) {
            cli::cli_abort("If getting monthly values, {.arg base} should be a date or easily coerced to one.")
        }
    } else {
        base <- suppressWarnings(as.numeric(base))
        if (any(is.na(base))) {
            cli::cli_abort("If getting annual values, {.arg base} should be a number or easily coerced to one.")
        }
    }
    series <- get_cpi_series(seasonal = seasonal, monthly_period = TRUE, current = TRUE)
    if (monthly) {
        base_year <- as.numeric(format(base, "%Y"))
    } else {
        base_year <- base
    }
    years_split <- cpi_yrs(years, base_year)
    query <- cpi_prep(series, years_split, verbose, key)

    cpi <- fetch_bls(query, verbose)
    cpi$value <- as.numeric(cpi$value)

    if (monthly) {
        cpi$date <- as.Date(paste(cpi$year, cpi$periodName, "01"), format = "%Y %B %d")
    } else {
        cpi$date <- as.numeric(cpi$year)
        cpi <- dplyr::group_by(cpi, date)
        cpi <- dplyr::summarise(cpi, value = mean(value))
        cpi <- dplyr::ungroup(cpi)
    }
    cpi <- dplyr::mutate(cpi, adj_factor = round(value / value[date == base], digits = 3))
    cpi <- dplyr::select(cpi, date, cpi = value, adj_factor)
    cpi <- dplyr::arrange(cpi, date)
    cpi
}

#################### HELPERS ##########################################
get_cpi_series <- function(seasonal, monthly_period, current) {
    # all boolean
    if (seasonal) {
        ssn <- "seasonal"
    } else {
        ssn <- "unseasonal"
    }
    if (monthly_period) {
        prd <- "monthly"
    } else {
        prd <- "semiannual"
    }
    if (current) {
        base <- "current"
    } else {
        base <- "alternative"
    }
    series <- dplyr::filter(
        cpi_series,
        seasonality == ssn,
        periodicity == prd,
        base_type == base
    )
    series[["id"]]
}

cpi_yrs <- function(year, base_year) {
    yr_range <- range(year)
    startyear <- min(c(yr_range[1], base_year))
    endyear <- max(c(yr_range[2], base_year))

    max_yrs <- 10
    years <- seq(startyear, endyear, by = 1)
    if (length(years) > max_yrs) {
        cli::cli_alert_info("The API can only get {max_yrs} years of data at once; making multiple calls, but this might take a little longer.")
    }
    years <- split_n(years, max_yrs)
    return(years)
}

cpi_prep <- function(series, years, catalog, key) {
    key <- check_bls_key(key)
    if (is.logical(key) && !key) {
        cli::cli_abort("Must supply an API key. See the docs on where to store it.",
            call = parent.frame()
        )
    }
    # make api query, call in main function
    base_url <- "https://api.bls.gov/publicAPI/v2/timeseries/data"
    params <- make_cpi_query(series, years, catalog, key)
    params <- purrr::map(params, function(p) list(url = base_url, body = p))
    params
}

make_cpi_query <- function(series, years, catalog, key) {
    purrr::map(years, function(yr) {
        startyear <- min(yr)
        endyear <- max(yr)
        list(
            seriesid = I(series),
            startyear = startyear,
            endyear = endyear,
            calculations = FALSE,
            catalog = catalog,
            registrationKey = key
        )
    })
}
