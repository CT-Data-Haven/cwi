#' Add inflation-adjusted values to a data frame
#'
#' This is modeled after `blscrapeR::inflation_adjust` that joins a data frame with an inflation adjustment table from the Bureau of Labor Statistics' Consumer Price Index, then calculates adjusted values. It returns the original data frame with two additional columns for adjustment factors and adjustment values.
#'
#' **Note:** Because `adj_inflation` makes API calls, internet access is required.
#'
#' According to the BLS research page, the series this uses is best suited to data going back to about 2000, when their methodology changed. For previous years, a more accurate version of the index is available on their [site](https://www.bls.gov/cpi/research-series/r-cpi-u-rs-home.htm).
#'
#' @param data A data frame containing monetary values by year.
#' @param value Bare column name of monetary values; for safety, has no default.
#' @param year Bare column name of years; for safety, has no default.
#' @param base_year Year on which to base inflation amounts. Defaults to 2021, which corresponds to saying "... adjusted to 2021 dollars."
#' @param verbose Logical: if `TRUE` (default), this will print overview information about the series being used, as returned by the API.
#' @param key A string giving the BLS API key. If `NULL` (the default), will take the value in `Sys.getenv("BLS_KEY")`.
#' @return A data frame with two additional columns: adjustment factors, and adjusted values. The adjusted values column is named based on the name supplied as `value`; e.g. if `value = avg_wage`, the adjusted column is named `adj_avg_wage`.
#' @examples
#' \dontrun{
#'   wages <- data.frame(
#'     fiscal_year = 2010:2016,
#'     wage = c(50000, 51000, 52000, 53000, 54000, 55000, 54000)
#'   )
#'   adj_inflation(wages, value = wage, year = fiscal_year, base_year = 2016)
#' }
#' @export
adj_inflation <- function(data, value, year, base_year = 2021, verbose = TRUE, key = NULL) {
  if (missing(value) || missing(year)) {
    cli::cli_abort("Must supply column names for both value and year.")
  }
  # series = c("CUUR0000SA0", "CUUR0000AA0")
  series <- "CUUR0000SA0"
  yr_lbl <- rlang::as_label(rlang::enquo(year))

  yr_range <- range(dplyr::pull(data, {{ year }}))
  startyear <- min(c(yr_range[1], base_year))
  endyear <- max(c(yr_range[2], base_year))

  query <- cpi_prep(series, startyear, endyear, verbose, key)

  fetch <- fetch_bls(query, verbose)

  cpi <- dplyr::mutate(fetch, dplyr::across(c(year, value), as.numeric))
  cpi <- dplyr::group_by(cpi, year)
  cpi <- dplyr::summarise(cpi, avg_cpi = mean(value))
  cpi <- dplyr::ungroup(cpi)
  cpi <- dplyr::mutate(cpi, adj_factor = round(avg_cpi / avg_cpi[year == base_year], digits = 3))
  cpi <- dplyr::select(cpi, year, adj_factor)

  adjusted <- dplyr::mutate(data, dplyr::across({{ year }}, as.numeric))
  adjusted <- dplyr::left_join(adjusted, cpi, by = stats::setNames("year", yr_lbl))
  adjusted <- dplyr::mutate(adjusted, dplyr::across({{ value }}, list(adj = ~. / adj_factor), .names = "{.fn}_{.col}"))
  adjusted
}

#################### HELPERS ##########################################
cpi_prep <- function(series, startyear, endyear, catalog, key) {
  key <- check_bls_key(key)
  if (is.logical(key) && !key) {
    cli::cli_abort("Must supply an API key. See the docs on where to store it.",
                   call = parent.frame())
  }
  # prep params
  max_yrs <- 10
  years <- seq(startyear, endyear, by = 1)
  if (length(years) > max_yrs) {
    cli::cli_alert_info("The API can only get {max_yrs} years of data at once; making multiple calls, but this might take a little longer.")
  }
  years <- split_n(years, max_yrs)

  # make api query, call in main function
  base_url <- "https://api.bls.gov/publicAPI/v2/timeseries/data"
  params <- make_cpi_query(series, years, catalog, key)
  params <- purrr::map(params, function(p) list(url = base_url, body = p))
  params
}

make_cpi_query <- function(series, years, catalog, key) {
  purrr::map(years, function(yr) {
    startyear <- min(yr); endyear <- max(yr)
    list(seriesid = I(series),
         startyear = startyear,
         endyear = endyear,
         calculations = FALSE,
         catalog = catalog,
         registrationKey = key)
  })
}


