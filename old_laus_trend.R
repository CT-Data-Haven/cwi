#' Fetch local area unemployment statistics (LAUS) data over time
#'
#' Fetch monthly LAUS data for a list of locations over a given time period, modeled after `blscrapeR::bls_api`. Requires a BLS API key.
#' @param names A character vector of place names to look up: as of now, this is limited to Connecticut, and its counties and towns.
#' @param startyear Numeric; first year of range
#' @param endyear Numeric; last year of range
#' @param measures A character vector of measures, containing any combination of `"unemployment rate"`, `"unemployment"`, `"employment"`, or `"labor force"`, or `"all"` (the default) as shorthand for all of the above.
#' @param annual Logical: whether to include annual averages along with monthly data. Defaults `FALSE`.
#' @param key A string giving the BLS API key. Defaults to the value in `Sys.getenv("BLS_KEY")`.
#' @return A data frame / tibble with columns for the measure, area, year, month number and name, value, series ID, and footnotes returned from the API.
#' @examples
#' \dontrun{
#' laus_trend(c("Connecticut", "New Haven", "Hamden"), 2014, 2017, annual = TRUE)
#' }
#' @export
laus_trend <- function(names, startyear, endyear, measures = "all", annual = FALSE, key = Sys.getenv("BLS_KEY")) {
  # make sure there's an API key
  assertthat::assert_that(!is.null(key), nchar(key) > 0, msg = "A BLS API key is required")
  # BLS API maxes at 20 years--split into groups of 20
  if (endyear - startyear > 20) {
    message("The API can only get 20 years of data at once; making multiple calls, but this might take a little longer.")
  }
  years_split <- split_n(startyear:endyear, 20)

  # make sure measures isn't something weird & invalid
  # measures lookup table
  if (identical(measures, "all")) {
    measure_lookup <- laus_measures
  } else {
    # assertthat::assert_that(all(measures %in% laus_measures$measure_text), msg = sprintf("Possible measures are %s, or all", paste(laus_measures$measure_text, collapse = ", ")))
    if (!all(measures %in% laus_measures[["measure_text"]])) stop(sprintf("Possible measures are %s, or all", paste(laus_measures[["measure_text"]], collapse = ", ")))
    measure_lookup <- dplyr::tibble(measure_text = measures) %>%
      dplyr::inner_join(laus_measures, by = "measure_text")
  }
  # laus area lookup table
  assertthat::assert_that(all(names %in% laus_codes[["area"]]), msg = "Limit names to valid Connecticut town and county names")
  areas <- laus_codes %>%
    dplyr::filter(area %in% names)

  # to make series IDs, get all combinations of measure codes and area codes
  series_df <- tidyr::crossing(measure_lookup, areas) %>%
    dplyr::select(area, area_code = code, measure_text, measure_code) %>%
    dplyr::mutate(series = sprintf("LAU%s%s", area_code, measure_code)) %>%
    dplyr::select(-area_code, -measure_code)

  # map over years_split, make calls for each
  out <- purrr::map_dfr(years_split, function(yrs) {
    get_laus(series_df$series, min(yrs), max(yrs), key, annual) %>%
      dplyr::left_join(series_df, by = "series") %>%
      dplyr::select(measure_text, area, year, period, periodName, value, series, footnotes)
  })

  out
}

get_laus <- function(series, startyear, endyear, key, annual) {
  if (length(series) == 1) series <- I(series)
  fetch <- httr::POST("https://api.bls.gov/publicAPI/v2/timeseries/data/",
                      body = list(seriesid = series,
                                  startyear = startyear,
                                  endyear = endyear,
                                  annualaverage = annual,
                                  registrationKey = key), encode = "json")

  laus <- httr::content(fetch)[["Results"]][["series"]]

  laus %>%
    purrr::map_dfr(function(l) {
      dt <- purrr::map_dfr(l[["data"]], dplyr::as_tibble) %>%
        dplyr::mutate(series = l[["seriesID"]])
    }) %>%
    dplyr::select(series, dplyr::everything()) %>%
    dplyr::mutate(dplyr::across(c(year, value), as.numeric))
}

