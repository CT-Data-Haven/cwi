#' Get employees counts and total payroll over time
#'
#' This gets data from the Quarterly Workforce Indicators (QWI) via the Census API. It's an alternative to `censusapi::getCensus` that fetches a set of variables (employees and payroll) but makes a somewhat more dynamic API call.
#' @param years A numeric vector of one or more years for which to get data
#' @param industries A character vector of NAICS industry codes; default is the 20 sectors plus "All industries" from the dataset `naics_codes`.
#' @param counties A character vector of county FIPS codes.
#' @param state A string of a state FIPS code; defaults to `"09"` for Connecticut
#' @param annual Logical, whether to return annual averages (default) or quarterly data.
#' @param key A Census API key. Defaults to the value at `"CENSUS_API_KEY"` in your `.Renviron` file, as set by `tidycensus::census_api_key`.
#' @return A data frame / tibble
#' @examples
#' \dontrun{
#' qwi_industry(2012:2017, industries = c("23", "62"), counties = "009")
#' }
#' @export
qwi_industry <- function(years, industries = naics_codes$industry, counties, state = "09", annual = TRUE, key = Sys.getenv("CENSUS_API_KEY")) {
  if (any(years < 1996)) stop("Data for Connecticut is only available for 1996 and after")
  base_url <- "https://api.census.gov/data/timeseries/qwi/se"
  get <- "Emp,Payroll"
  ind_list <- as.list(industries)
  names(ind_list) <- rep("industry", length(ind_list))
  year_str <- paste(years, collapse = ",")
  county_str <- stringr::str_pad(counties, width = 3, side = "left", pad = "0") %>%
    paste(collapse = ",") %>%
    sprintf("county:%s", .)
  state_str <- paste0("state:", stringr::str_pad(state, width = 2, side = "left", pad = "0"))
  quarter_str <- paste(1:4, collapse = ",")
  params <- list(
    key = key,
    get = get,
    "for" = county_str,
    "in" = state_str,
    year = year_str,
    quarter = quarter_str
  )
  params <- c(params, ind_list)
  request <- httr::GET(base_url, query = params)
  data <- jsonlite::fromJSON(httr::content(request, as = "text"))
  colnames(data) <- data[1, ]

  out <- tibble::as_tibble(data[-1, ]) %>%
    dplyr::select(year:county, tidyselect::everything()) %>%
    dplyr::mutate_at(dplyr::vars(year, Emp, Payroll), as.numeric)

  if (annual) {
    out %>%
      dplyr::group_by(year, industry, state, county) %>%
      dplyr::summarise(Emp = mean(Emp), Payroll = sum(Payroll)) %>%
      dplyr::ungroup()
  } else {
    out
  }
}
