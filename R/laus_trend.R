#' Fetch local area unemployment statistics (LAUS) data over time
#'
#' Fetch monthly LAUS data for a list of locations over a given time period. Requires a BLS API key; see [blscrapeR::set_bls_key()].
#' @param names A character vector of place names to look up: as of now, this is limited to Connecticut, and its counties and towns.
#' @param startyear Numeric; first year of range
#' @param endyear Numeric; last year of range
#' @param measures A character vector of measures, containing any combination of `"unemployment rate"`, `"unemployment"`, `"employment"`, or `"labor force"`, or `"all"` (the default) as shorthand for all of the above.
#' @param annual Logical: whether to include annual averages along with monthly data. Defaults `FALSE`.
#' @param key A string giving the BLS API key. Defaults to the value in `Sys.getenv("BLS_KEY")`, as set by `blscrapeR::set_bls_key`.
#' @return A data frame / tibble with columns for the measure, area, year, month number and name, value, series ID, and footnotes returned from the API.
#' @examples
#' \dontrun{
#' laus_trend(c("New Haven", "Hamden"), 2014, 2017, annual = TRUE)
#' }
#' @export
laus_trend <- function(names, startyear, endyear, measures = "all", annual = FALSE, key = Sys.getenv("BLS_KEY")) {
  # make sure there's an API key
  assertthat::assert_that(!is.null(key), nchar(key) > 0, msg = "A BLS API key is required. Please see blscrapeR::set_bls_key for installation")
  # BLS API maxes at 20 years--split into groups of 20
  if (endyear - startyear > 20) {
    message("The API can only get 20 years of data at once; making multiple calls, but this might take a little longer.")
  }
  year_df <- data.frame(years = startyear:endyear)
  year_df$brk <- floor(year_df$years / 20)
  years_split <- split(year_df, year_df$brk) %>%
    purrr::map(dplyr::pull, years)

  # make sure measures isn't something weird & invalid
  # measures lookup table
  if (identical(measures, "all")) {
    measure_lookup <- laus_measures
  } else {
    # assertthat::assert_that(all(measures %in% laus_measures$measure_text), msg = sprintf("Possible measures are %s, or all", paste(laus_measures$measure_text, collapse = ", ")))
    if (!all(measures %in% laus_measures$measure_text)) stop(sprintf("Possible measures are %s, or all", paste(laus_measures$measure_text, collapse = ", ")))
    measure_lookup <- dplyr::data_frame(measure_text = measures) %>%
      dplyr::inner_join(laus_measures, by = "measure_text")
  }
  # laus area lookup table
  assertthat::assert_that(all(names %in% laus_codes$area), msg = "Limit names to valid Connecticut town and county names")
  areas <- laus_codes %>%
    dplyr::filter(area %in% names)

  # to make series IDs, get all combinations of measure codes and area codes
  series_df <- tidyr::crossing(measure_lookup, areas) %>%
    dplyr::select(area, area_code = code, measure_text, measure_code) %>%
    dplyr::mutate(series = sprintf("LAU%s%s", area_code, measure_code)) %>%
    dplyr::select(-area_code, -measure_code)

  # map over years_split, make calls for each
  out <- purrr::map_dfr(years_split, function(yrs) {
    y1 <- min(yrs)
    y2 <- max(yrs)
    blscrapeR::bls_api(seriesid = series_df$series, startyear = y1, endyear = y2, registrationKey = key, annualaverage = annual) %>%
      dplyr::left_join(series_df, by = c("seriesID" = "series")) %>%
      dplyr::select(measure_text, area, year, period, periodName, value, seriesID, footnotes)
  })

  out
}

