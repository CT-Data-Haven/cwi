#' Fetch local area unemployment statistics (LAUS) data over time
#'
#' Fetch monthly LAUS data for a list of towns over a given time period. Requires a BLS API key; see [blscrapeR::set_bls_key()].
#' @param towns A character vector of place names to look up: as of now, this is limited to Connecticut, and its counties and towns.
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
laus_trend <- function(towns, startyear, endyear, measures = "all", annual = FALSE, key = Sys.getenv("BLS_KEY")) {
  if (identical(measures, "all")) {
    measure_lookup <- laus_measures
  } else {
    assertthat::assert_that(all(measures %in% laus_measures$measure_text), msg = sprintf("Possible measures are %s, or all", paste(laus_measures$measure_text, collapse = ", ")))
    measure_lookup <- dplyr::data_frame(measure_text = measures) %>%
      dplyr::inner_join(laus_measures, by = "measure_text")
  }
  assertthat::assert_that(all(towns %in% laus_codes$area), msg = "Limit towns to valid Connecticut town and county names")
  areas <- laus_codes %>%
    dplyr::filter(area %in% towns)

  series_df <- tidyr::crossing(measure_lookup, areas) %>%
    dplyr::select(area, area_code = code, measure_text, measure_code) %>%
    dplyr::mutate(series = sprintf("LAU%s%s", area_code, measure_code)) %>%
    dplyr::select(-area_code, -measure_code)

  blscrapeR::bls_api(seriesid = series_df$series, startyear = startyear, endyear = endyear, registrationKey = key, annualaverage = annual) %>%
    dplyr::left_join(series_df, by = c("seriesID" = "series")) %>%
    dplyr::select(measure_text, area, year, period, periodName, value, seriesID, footnotes)
}
