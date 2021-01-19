#' Add inflation-adjusted values to a data frame
#'
#' This is modeled after `blscrapeR::inflation_adjust` that joins a data frame with an inflation adjustment table from the Bureau of Labor Statistics, then calculates adjusted values. It returns the original data frame with two additional columns for adjustment factors and adjustment values.
#'
#' **Note:** Because `adj_inflation` makes API calls, internet access is required.
#'
#' @param .data A data frame containing monetary values by year.
#' @param value Bare column name of monetary values; for safety, has no default.
#' @param year Bare column name of years; for safety, has no default.
#' @param base_year Year on which to base inflation amounts; defaults to 2019.
#' @param key A string giving the BLS API key. Defaults to the value in `Sys.getenv("BLS_KEY")`.
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
adj_inflation <- function(.data, value, year, base_year = 2019, key = Sys.getenv("BLS_KEY")) {
  if (missing(value) | missing(year)) stop("Both value and year are required.")
  assertthat::assert_that(curl::has_internet(), msg = "Internet access is required to run this function.")

  value_var <- rlang::enquo(value)
  year_var <- rlang::enquo(year)

  adj_var <- paste("adj", rlang::as_label(value_var), sep = "_")

  yr_range <- range(.data[rlang::as_label(year_var)])
  startyear <- min(c(yr_range[1], base_year))
  endyear <- max(c(yr_range[2], base_year))

  # API only handles 20 years at a time
  if (endyear - startyear > 10) {
    message("The API can only get 10 years of data at once; making multiple calls, but this might take a little longer.")
  }
  years_split <- split_n(startyear:endyear, 10)

  cpi <- purrr::map_dfr(years_split, function(yrs) {
    get_cpi(min(yrs), max(yrs), key = key)
  }) %>%
    dplyr::select(year, period, value) %>%
    dplyr::group_by(year) %>%
    dplyr::summarise(avg_cpi = mean(value)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(adj_factor = round(avg_cpi / avg_cpi[year == base_year], 3)) %>%
    dplyr::select(-avg_cpi)

  .data %>%
    dplyr::mutate(dplyr::across({{ year_var }}, as.numeric)) %>%
    dplyr::left_join(cpi, by = stats::setNames("year", rlang::as_label(year_var))) %>%
    dplyr::mutate({{ adj_var }} := {{ value_var }} / adj_factor)
}

get_cpi <- function(startyear, endyear, key) {
  cpi_series <- "CUSR0000SA0"

  fetch <- httr::POST("https://api.bls.gov/publicAPI/v2/timeseries/data/",
                      body = list(seriesid = I(c(cpi_series)),
                                  startyear = startyear,
                                  endyear = endyear,
                                  annualaverage = FALSE,
                                  registrationKey = key), encode = "json")

  cpi_data <- httr::content(fetch)[["Results"]][["series"]][[1]][["data"]]

  purrr::map_dfr(cpi_data, dplyr::as_tibble) %>%
    dplyr::mutate(dplyr::across(c(year, value), as.numeric))
}

