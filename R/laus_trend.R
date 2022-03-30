#' Fetch local area unemployment statistics (LAUS) data over time
#'
#' Fetch monthly LAUS data for a list of locations over a given time period, modeled after `blscrapeR::bls_api`. Requires a BLS API key.
#' @param names A character vector of place names to look up, either towns and/or counties.
#' @param startyear Numeric; first year of range
#' @param endyear Numeric; last year of range
#' @param state A string: either name or two-digit FIPS code of a US state. Required; defaults `"09"` (Connecticut).
#' @param measures A character vector of measures, containing any combination of `"unemployment rate"`, `"unemployment"`, `"employment"`, or `"labor force"`, or `"all"` (the default) as shorthand for all of the above.
#' @param annual Logical: whether to include annual averages along with monthly data. Defaults `FALSE`.
#' @param verbose Logical: if `TRUE` (default), this will print overview information about the series being used, as returned by the API.
#' @param key A string giving the BLS API key. If `NULL` (the default), will take the value in `Sys.getenv("BLS_KEY")`.
#' @return A data frame, slightly cleaned up from what the API returns.
#' @examples
#' \dontrun{
#' laus_trend(c("Connecticut", "New Haven", "Hamden"), 2014, 2017, annual = TRUE)
#' }
#' @export
laus_trend <- function(names = NULL, startyear, endyear, state = "09", measures = "all", annual = FALSE, verbose = TRUE, key = NULL) {
  # check measures
  series <- make_laus_series(names, state, measures)
  query <- laus_prep(series, startyear, endyear, annual, verbose, key)

  fetch <- fetch_bls(query, verbose)

  laus <- dplyr::left_join(series, fetch, by = c("series" = "seriesID"))
  laus$date <- as.Date(paste(laus$year, laus$periodName, "01"), format = "%Y %B %d")
  laus$measure_text <- forcats::fct_relabel(laus$measure_text, function(x) gsub("\\W", "_", x))
  laus <- dplyr::mutate(laus, dplyr::across(c(year, value), as.numeric))
  laus <- dplyr::arrange(laus, date)
  laus <- dplyr::select(laus, state_code, area, measure_text, periodName, year, date, value)
  laus <- tidyr::pivot_wider(laus, names_from = measure_text, values_from = value)

  laus
}


laus_prep <- function(series_df, startyear, endyear, annual, verbose, key) {
  key <- check_bls_key(key)
  if (is.logical(key) && !key) {
    cli::cli_abort("Must supply an API key. See the docs on where to store it.",
                   call = parent.frame())
  }

  max_yrs <- 20
  years <- seq(startyear, endyear, by = 1)
  if (length(years) >= max_yrs) {
    cli::cli_alert_info("The API can only get {max_yrs} years of data at once; making multiple calls, but this might take a little longer.")
  }
  years <- split_n(years, max_yrs)


  # make api query
  base_url <- "https://api.bls.gov/publicAPI/v2/timeseries/data"
  params <- make_laus_query(series_df$series, years, annual, verbose, key)
  params <- purrr::map(params, function(p) list(url = base_url, body = p))
  params
}

make_laus_series <- function(names, state, measures) {
  # check measures
  measures <- check_laus_vars(measures)
  if (is.logical(measures) && !measures) {
    cli::cli_abort(c("The argument supplied to {.arg measures} is invalid.",
                     "i" = "See {.var laus_measures} for valid options, or use {.val all} for all measures."),
                   call = parent.frame())
  }

  # check state, convert / copy to fips
  if (is.null(state) | length(state) > 1) {
    cli::cli_abort("Must supply a single state by name, abbreviation, or FIPS code.",
                   call = parent.frame())
  }
  state_fips <- get_state_fips(state)

  # check names--if null, use all in state
  locs <- check_laus_names(state_fips, names)
  if (nrow(locs) < length(names)) {
    if (nrow(locs) < 1) {
      cli::cli_abort("No locations were found. Double check your state and locations.")
    } else {
      missing_locs <- setdiff(names, locs[["area"]])
      cli::cli_warn("No results were found for {.val {missing_locs}}. Double check your spelling.")
    }
  }

  all_codes <- merge(locs, measures, by = NULL)
  all_codes$series <- paste0("LAU", all_codes$area_code, all_codes$measure_code)
  all_codes
}

make_laus_query <- function(series, years, annual, verbose, key) {
  if (length(series) == 1) series <- I(series)
  purrr::map(years, function(yr) {
    startyear <- min(yr); endyear <- max(yr)
    list(seriesid = series,
         startyear = startyear,
         endyear = endyear,
         annualaverage = annual,
         calculations = FALSE,
         catalog = verbose,
         registrationKey = key)
    # jsonlite::toJSON(p, auto_unbox = TRUE)
  })
}

check_laus_vars <- function(measures) {
  if (identical(measures, "all") | is.null(measures)) {
    measure_lookup <- laus_measures
  } else {
    measure_lookup <- laus_measures[laus_measures$measure_code %in% measures | laus_measures$measure_text %in% measures, ]
    mismatch <- setdiff(measures, c(laus_measures$measure_code, laus_measures$measure_text))
    if (length(mismatch) > 0) {
      return(FALSE)
    }
  }
  return(measure_lookup)
}

check_laus_names <- function(state, names) {
  codes <- laus_codes[laus_codes$state_code %in% state, ]
  if (!is.null(names)) {
    codes <- codes[codes$area %in% names, ]
  }
  codes
}



