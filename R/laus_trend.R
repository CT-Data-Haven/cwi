laus_prep <- function(series_df, startyear, endyear, key) {
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
  params <- make_laus_query(series_df$series, years, key)
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

  # check names--if null, use all in state
  state_fips <- get_state_fips(state)
  locs <- check_laus_names(state_fips, names)
  if (nrow(locs) < 1) {
    cli::cli_abort("No locations were found.")
  }

  all_codes <- merge(locs, measures, by = NULL)
  all_codes$series <- paste0("LAU", all_codes$area_code, all_codes$measure_code)
  all_codes
}

make_laus_query <- function(series, years, key) {
  if (length(series) == 1) series <- I(series)
  purrr::map(years, function(yr) {
    startyear <- min(yr); endyear <- max(yr)
    list(seriesid = series,
         startyear = startyear,
         endyear = endyear,
         annualaverage = FALSE,
         calculations = FALSE,
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

#' @export
laus_trend <- function(names = NULL, startyear, endyear, state = "09", measures = "all", annual = FALSE, key = NULL) {
  # if names null, use all in state
  # names <- check_laus_names(state, names)

  # check measures
  series <- make_laus_series(names, state, measures)
  query <- laus_prep(series, startyear, endyear, key)
  agent <- httr::user_agent("cwi")
  fetch <- purrr::map(query, function(q) {
    httr::POST(q$url, body = q$body, encode = "json", agent, httr::timeout(10))
  })
  fetch <- purrr::map(fetch, httr::content, as = "text", encoding = "utf-8")
  fetch <- purrr::map(fetch, jsonlite::fromJSON)
  fetch <- purrr::map(fetch, purrr::pluck, "Results", "series")
  fetch <- purrr::map_dfr(fetch, dplyr::as_tibble)
  fetch <- tidyr::unnest(fetch, data)

  laus <- dplyr::left_join(series, fetch, by = c("series" = "seriesID"))
  laus$date <- lubridate::ym(paste(laus$year, laus$periodName))
  laus$measure_text <- forcats::fct_relabel(laus$measure_text, function(x) gsub("\\W", "_", x))
  laus <- dplyr::mutate(laus, dplyr::across(c(year, value), as.numeric))
  laus <- dplyr::arrange(laus, date, type, measure_code)
  laus <- dplyr::select(laus, type, state_code, area, measure_text, date, year, value)
  laus <- tidyr::pivot_wider(laus, names_from = measure_text, values_from = value)

  if (annual) {
  # add unemployment, employment, labor force, civilian noninstitutional population
  # calculate unemployment rate, employment-population ratio, labor force participation rate
    laus <- calc_annual_laus(laus)
  }
  laus
}

calc_annual_laus <- function(laus) {
  meas <- names(laus)
  laus <- dplyr::group_by(laus, type, state_code, area, year)
  laus <- dplyr::summarise(laus, dplyr::across(tidyselect::any_of(c("unemployment", "employment", "labor_force", "civilian_noninstitutional_population")), sum))
  laus <- dplyr::ungroup(laus)
  if ("unemployment_rate" %in% meas) {
    if (!all(c("unemployment", "labor_force") %in% meas)) {
      cli::cli_warn(c("Annual unemployment rate can't be calculated without including the unemployment and labor force measures.",
                      "i" = "Adjust the {.var measures} argument, or use {.val all} to get all measures."))
    } else {
      laus$unemployment_rate <- laus$unemployment / laus$labor_force
    }
  }
  if ("employment_population_ratio" %in% meas) {
    if (!all(c("employment", "civilian_noninstitutional_population") %in% meas)) {
      cli::cli_warn(c("Annual employment-population ratio can't be calculated without including the employment and population measures.",
                      "i" = "Adjust the {.var measures} argument, or use {.val all} to get all measures."))
    } else {
      laus$employment_population_ratio <- laus$employment / laus$civilian_noninstitutional_population
    }
  }
  if ("labor_force_participation_rate" %in% meas) {
    if (!all(c("labor_force", "civilian_noninstitutional_population") %in% meas)) {
      cli::cli_warn(c("Annual labor force participation rate can't be calculated without including labor force and population measures.",
                      "i" = "Adjust the {.var measures} argument, or use {.val all} to get all measures."))
    } else {
      laus$labor_force_participation_rate <- laus$labor_force / laus$civilian_noninstitutional_population
    }
  }
  laus
}
