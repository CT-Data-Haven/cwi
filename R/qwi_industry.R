#' Get employment counts and total payroll over time
#'
#' This gets data from the Quarterly Workforce Indicators (QWI) via the Census API. It's an alternative to `censusapi` that fetches a set of variables (employees and payroll) but makes a somewhat more dynamic API call. The API returns a maximum of 10 years of data; calling this function with more than 10 years will require multiple API calls, which takes a little longer.
#'
#' Note that when looking at data quarterly, the payroll reported will be for that quarter, not the yearly payroll that you may be more accustomed to. As of November 2021, payroll data seems to be missing from the database; even the QWI Explorer app just turns up empty.
#' @param years A numeric vector of one or more years for which to get data
#' @param industries A character vector of NAICS industry codes; default is the 20 sectors plus "All industries" from the dataset `naics_codes`.
#' @param state A string of length 1 representing a state's FIPS code, name, or two-letter abbreviation; defaults to `"09"` for Connecticut
#' @param counties A character vector of county FIPS codes, or `"all"` for all counties. If `NULL` (the default), will return data just at the state level. For Connecticut, these now need to be COGs; data has been changed retroactively.
#' @param annual Logical, whether to return annual averages or quarterly data (default) .
#' @param key A Census API key. If `NULL`, defaults to the environmental variable `"CENSUS_API_KEY"`, as set by `tidycensus::census_api_key()`.
#' @param retry The number of times to retry the API call(s), since the server this comes from can be a bit finicky.
#' @return A data frame / tibble
#' @examples
#' \dontrun{
#' qwi_industry(2012:2017, industries = c("23", "62"), counties = "170")
#' }
#' @keywords fetching-functions
#' @export
qwi_industry <- function(years, industries = cwi::naics_codes[["industry"]],
                         state = "09", counties = NULL,
                         annual = FALSE, key = NULL, retry = 5) {
    urls <- qwi_prep(
        years = years,
        industries = industries,
        state = state,
        counties = counties,
        key = key
    )
    if (length(urls) == 0) {
        # add hint if looking for CT counties
        msg <- "An error occurred in preparing your API calls."
        if (state %in% c("09", "CT") & !is.null(counties)) {
            msg <- c(msg, "i" = "This API retroactively replaced counties with COGs--double check your arguments.")
        }
        cli::cli_abort(msg, call = parent.frame(n = 3))
    }

    response <- purrr::map(urls, \(u) call_qwi(u, retry))
    result <- purrr::map(response, \(x) x[["result"]])
    success <- purrr::map_lgl(response, \(x) x[["success"]])
    if (!all(success)) {
        fails <- purrr::keep(response, \(x) !x[["success"]])
        status <- purrr::map_chr(fails, \(x) x[["result"]])
        if ("No Content" %in% status) {
            cli::cli_abort(c(
                "One or more of your API calls came back empty.",
                "i" = "Double check your arguments, especially the industry codes."
            ), call = parent.frame(n = 2))
        } else {
            cli::cli_abort(c(
                "An error occurred in making one or more API calls.",
                "x" = unique(status)
            ), call = parent.frame(n = 3))
        }
    }

    fetch <- dplyr::bind_rows(result)
    fetch <- dplyr::mutate(fetch, dplyr::across(c(quarter, Emp, Payroll, year), as.numeric))
    fetch <- dplyr::as_tibble(fetch)
    fetch <- dplyr::select(
        fetch,
        year, quarter, state, tidyselect::any_of("county"), industry,
        tidyselect::everything()
    )
    fetch <- clean_names(fetch)

    # if annual
    if (annual) {
        fetch <- dplyr::group_by(fetch, year, state, dplyr::across(tidyselect::any_of("county")), industry)
        fetch <- dplyr::summarise(fetch, emp = mean(emp), payroll = sum(payroll))
        fetch <- dplyr::ungroup(fetch)
    } else {
        # make dates from quarters
        fetch$date <- as.Date(paste(fetch$year, (fetch$quarter - 1) * 3 + 1, "01"), format = "%Y %m %d")
        fetch <- dplyr::select(fetch, year, quarter, date, tidyselect::everything())
    }
    fetch
}


#################### HELPERS ##########################################
qwi_prep <- function(years, industries, state, counties, key) {
    # uses a weird way to estimate number of records, crashes if too many
    # so if getting counties, do one at a time
    key <- check_census_key(key)
    if (is.logical(key) && !key) {
        cli::cli_abort("Must supply an API key. See the docs on where to store it.",
            call = parent.frame()
        )
    }
    # check state, convert / copy to fips
    if (is.null(state) | length(state) > 1) {
        cli::cli_abort("Must supply a single state by name, abbreviation, or FIPS code.",
            call = parent.frame()
        )
    }
    state_fips <- get_state_fips(state)
    if (is.null(state_fips)) {
        cli::cli_abort("{state} is not a valid state name, abbreviation, or FIPS code.",
            call = parent.frame()
        )
    }
    # check counties--if null, don't include
    # update 5/2024--uses cogs now
    if (!is.null(counties)) {
        counties <- substr(get_county_fips(state_fips, counties, use_cogs = TRUE), 3, 5)
    }
    # get available years for state
    # will throw error--not the best place for that
    max_yrs <- 10
    years <- prep_qwi_yrs(years, state_fips, max_yrs)

    # build GET params
    base_url <- "https://api.census.gov/data/timeseries/qwi/se"
    params <- make_qwi_query(years, industries, state_fips, counties, key)

    urls <- purrr::map(params, function(p) {
        httr::modify_url(base_url, query = p)
    })
    urls
}

prep_qwi_yrs <- function(yrs_asked, state_fips, api_len) {
    # adjust column names if necessary, altho state_code name comes from tidycensus
    asked_range <- range(yrs_asked)
    # cache results of checking qwi availability
    # mem_check_qwi <- memoise::memoise(check_qwi_avail, cache = prep_cache())
    qwi_avail <- check_qwi_avail()
    yrs_avail <- as.list(qwi_avail[qwi_avail$state_code == state_fips, ])
    avail_range <- seq(from = yrs_avail$start_year, to = yrs_avail$end_year)
    unavail <- setdiff(yrs_asked, avail_range)
    if (!any(yrs_asked %in% avail_range)) {
        cli::cli_abort(
            c("Data for {state_fips} are only available from {yrs_avail$start_year} to {yrs_avail$end_year}.",
                "i" = "You requested data between {asked_range[1]} and {asked_range[2]}."
            ),
            call = parent.frame()
        )
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

call_qwi <- function(url, retry) {
    agent <- httr::user_agent("cwi")
    resp <- httr::RETRY("GET", url, agent, times = retry)
    # if 200, parse & return results
    # otherwise return status
    status <- httr::http_status(resp)[["reason"]]
    if (status == "OK") {
        fetch <- httr::content(resp, as = "text")
        # if bad key is used, still returns 200
        if (grepl("\\<html", fetch)) {
            list(result = "Invalid key", success = FALSE)
        } else {
            fetch <- jsonlite::fromJSON(fetch)
            colnames(fetch) <- fetch[1, ]
            fetch <- as.data.frame(fetch[-1, ])
            list(result = fetch, success = TRUE)
        }
    } else {
        list(result = status, success = FALSE)
    }
}
