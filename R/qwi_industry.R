qwi_prep <- function(years, industries, state, counties, key) {
  # uses a weird way to estimate number of records, crashes if too many
  # so if getting counties, do one at a time
  key <- check_census_key(key)
  if (is.logical(key) && !key) {
    cli::cli_abort("Must supply an API key. See the docs on where to store it.",
                   call = parent.frame())
  }
  # check state, convert / copy to fips
  if (is.null(state) | length(state) > 1) {
    cli::cli_abort("Must supply a single state by name, abbreviation, or FIPS code.",
                   call = parent.frame())
  }
  state_fips <- get_state_fips(state)
  if (is.null(state_fips)) {
    cli::cli_abort("{state} is not a valid state name, abbreviation, or FIPS code.",
                   call = parent.frame())
  }
  # check counties--if null, don't include
  if (!is.null(counties)) {
    counties <- substr(get_county_fips(state_fips, counties), 3, 5)
  }
  # get available years for state
  # will throw error--not the best place for that
  max_yrs <- 10
  years <- check_avail_years(years, state_fips, qwi_avail, max_yrs)

  # build GET params
  base_url <- "https://api.census.gov/data/timeseries/qwi/se"
  params <- make_qwi_query(years, industries, state_fips, counties, key)

  urls <- purrr::map(params, function(p) {
    httr::modify_url(base_url, query = p)
  })
  urls
}

check_avail_years <- function(yrs_asked, state_fips, lookup, api_len) {
  # adjust column names if necessary, altho state_code name comes from tidycensus
  asked_range <- range(yrs_asked)
  yrs_avail <- as.list(lookup[lookup$state_code == state_fips, ])
  avail_range <- seq(from = yrs_avail$start_year, to = yrs_avail$end_year)
  unavail <- setdiff(yrs_asked, avail_range)
  if (!any(yrs_asked %in% avail_range)) {
    cli::cli_abort(c("Data for {state_fips} are only available from {yrs_avail$start_year} to {yrs_avail$end_year}.",
                     "i" = "You requested data between {asked_range[1]} and {asked_range[2]}."),
                   call = parent.frame())
  }
  if (length(unavail) > 0) {
   cli::cli_warn("Data for state {state_fips} are only available from {yrs_avail$start_year} to {yrs_avail$end_year}. Additional years will be dropped.")
    yrs_asked <- yrs_asked[yrs_asked %in% avail_range]
  }

  # api only takes 10 yrs at a time--split if needed
  if (length(yrs_asked) > api_len) {
    cli::cli_alert_info("The API can only get {api_len} years of data at once; making multiple calls, but this might take a little longer.")
  }
  split_n(yrs_asked, api_len)
}

make_qwi_query <- function(years, industries, state, counties, key) {
  # same params for every call
  get <- "Emp,Payroll"
  industries <- rlang::set_names(as.list(industries), "industry")
  state_str <- paste("state", state, sep = ":")
  quarter_str <- paste(1:4, collapse = ",")
  base_params <- list(
    key = key,
    get = get,
    quarter = quarter_str
  )
  base_params <- c(base_params, industries)

  # params that depend on counties, years
  params <- purrr::map(years, function(yr) {
    if (!is.null(counties)) {
      by_yr <- purrr::map(counties, function(county) {
        county_str <- paste("county", county, sep = ":")
        p <- base_params
        p[["for"]] <- county_str
        p[["in"]] <- state_str
        p
      })
    } else {
      p <- base_params
      p[["for"]] <- state_str
      by_yr <- list(p)
    }
    by_yr <- purrr::map(by_yr, function(y) {
      y[["year"]] <- paste(yr, collapse = ",")
      y
    })
    by_yr
  })

  purrr::flatten(params)
}

#' Get employees counts and total payroll over time
#'
#' This gets data from the Quarterly Workforce Indicators (QWI) via the Census API. It's an alternative to `censusapi` that fetches a set of variables (employees and payroll) but makes a somewhat more dynamic API call. The API returns a maximum of 10 years of data; calling this function with more than 10 years will require multiple API calls, which takes a little longer.
#'
#' Note that when looking at data quarterly, the payroll reported will be for that quarter, not the yearly payroll that you may be more accustomed to. As of November 2021, payroll data seems to be missing from the database; even the QWI Explorer app just turns up empty.
#' @param years A numeric vector of one or more years for which to get data
#' @param industries A character vector of NAICS industry codes; default is the 20 sectors plus "All industries" from the dataset `naics_codes`.
#' @param state A string of length 1 representing a state's FIPS code, name, or two-letter abbreviation; defaults to `"09"` for Connecticut
#' @param counties A character vector of county FIPS codes, or `"all"` for all counties (the default). If `NULL`, will return data just at the state level.
#' @param annual Logical, whether to return annual averages or quarterly data (default) .
#' @param key A Census API key. If `NULL`, defaults to the environmental variable `"CENSUS_API_KEY"`, as set by `tidycensus::census_api_key()`.
#' @return A data frame / tibble
#' @examples
#' \dontrun{
#' qwi_industry(2012:2017, industries = c("23", "62"), counties = "009")
#' }
#' @export
qwi_industry <- function(years, industries = naics_codes[["industry"]],
                         state = "09", counties = NULL,
                         annual = FALSE, key = NULL, retry = 5) {
  urls <- qwi_prep(years = years,
                   industries = industries,
                   state = state,
                   counties = counties,
                   key = key)
  agent <- httr::user_agent("cwi")

  fetch <- purrr::imap(urls, function(u, i) {
    # httr::GET(u, agent)
    resp <- httr::RETRY("GET", u, agent, times = retry) # census is really playing games
    if (httr::http_error(resp)) {
      cli::cli_abort(c("An error occurred in making one or more API calls.",
                       "x" = httr::http_status(resp)[["message"]]),
                     call = parent.frame(n = 3))
    }
    resp
  })
  fetch <- purrr::map(fetch, httr::content, as = "text")
  fetch <- purrr::map(fetch, jsonlite::fromJSON)
  fetch <- purrr::map(fetch, function(mtx) {
    colnames(mtx) <- mtx[1, ]
    mtx[-1, ]
  })
  fetch <- purrr::map(fetch, as.data.frame)
  fetch <- dplyr::bind_rows(fetch)
  fetch <- dplyr::mutate(fetch, dplyr::across(c(quarter, Emp, Payroll, year), as.numeric))
  fetch <- dplyr::as_tibble(fetch)
  fetch <- dplyr::select(fetch,
                         year, quarter, state, tidyselect::any_of("county"), industry,
                         dplyr::everything())
  fetch <- janitor::clean_names(fetch)
  # if annual

  if (annual) {
    fetch <- dplyr::group_by(fetch, year, state, dplyr::across(tidyselect::any_of("county")), industry)
    fetch <- dplyr::summarise(fetch, emp = mean(emp), payroll = sum(payroll))
    fetch <- dplyr::ungroup(fetch)
  }
  fetch
}

