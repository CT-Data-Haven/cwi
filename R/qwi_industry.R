#' Get employees counts and total payroll over time
#'
#' This gets data from the Quarterly Workforce Indicators (QWI) via the Census API. It's an alternative to `censusapi` that fetches a set of variables (employees and payroll) but makes a somewhat more dynamic API call. The API returns a maximum of 10 years of data; calling this function with more than 10 years will require multiple API calls, which takes a little longer.
#'
#' Note that when looking at data quarterly, the payroll reported will be for that quarter, not the yearly payroll that you may be more accustomed to.
#' @param years A numeric vector of one or more years for which to get data
#' @param industries A character vector of NAICS industry codes; default is the 20 sectors plus "All industries" from the dataset `naics_codes`.
#' @param counties A character vector of county FIPS codes.
#' @param state A string of a state FIPS code; defaults to `"09"` for Connecticut
#' @param annual Logical, whether to return annual averages (default) or quarterly data.
#' @param key A Census API key. Defaults to the value at `"CENSUS_API_KEY"` in your `.Renviron` file, as set by `tidycensus::census_api_key()`.
#' @return A data frame / tibble
#' @examples
#' \dontrun{
#' qwi_industry(2012:2017, industries = c("23", "62"), counties = "009")
#' }
#' @export
qwi_industry <- function(years, industries = naics_codes$industry, counties = NULL, state = "09", annual = TRUE, key = Sys.getenv("CENSUS_API_KEY")) {
  assertthat::assert_that(!is.null(key), nchar(key) > 0, msg = "A Census API key is required. Please see tidycensus::census_api_key for installation")

  if (all(years < 1996)) stop("Data for Connecticut is only available for 1996 and after.")

  if (any(years < 1996)) {
    years <- years[years >= 1996]
    warning("Data for Connecticut is only available for 1996 and after. Any earlier years are being removed.")
  }

  if (length(years) > 10) {
    message("The API can only get 10 years of data at once; making multiple calls, but this might take a little longer.")
  }
  year_df <- data.frame(years = years, brk = floor(years / 10))
  years_split <- split(year_df, year_df$brk) %>%
    purrr::map(dplyr::pull, years)
  base_url <- "https://api.census.gov/data/timeseries/qwi/se"
  get <- "Emp,Payroll"
  ind_list <- as.list(industries)
  names(ind_list) <- rep("industry", length(ind_list))
  state_str <- paste0("state:", stringr::str_pad(state, width = 2, side = "left", pad = "0"))
  quarter_str <- paste(1:4, collapse = ",")

  out <- purrr::map_dfr(years_split, function(yrs) {
    year_str <- paste(yrs, collapse = ",")
    params <- list(
      key = key,
      get = get,
      year = year_str,
      quarter = quarter_str
    )

    if (!is.null(counties)) {
      county_join <- stringr::str_pad(counties, width = 3, side = "left", pad = "0") %>%
        paste(collapse = ",")
      county_str <- sprintf("county:%s", county_join)
      params$`for` <- county_str
      params$`in` <- state_str
    } else {
      params$`for` <- state_str
    }

    params <- c(params, ind_list)
    request <- httr::GET(base_url, query = params)
    data <- jsonlite::fromJSON(httr::content(request, as = "text"))
    colnames(data) <- data[1, ]

    dplyr::as_tibble(data[-1, ]) %>%
      dplyr::mutate_at(dplyr::vars(quarter, Emp, Payroll), as.numeric)
  })


  if (annual) {
    out %>%
      dplyr::group_by_if(is.character) %>%
      dplyr::summarise(Emp = round(mean(Emp)), Payroll = sum(Payroll)) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(year = as.numeric(year))
  } else {
    out %>%
      dplyr::mutate(year = as.numeric(year))
  }
}
