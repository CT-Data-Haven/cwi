cpi_prep <- function(series, startyear, endyear, key) {
  key <- check_bls_key(key)
  if (is.logical(key) && !key) {
    cli::cli_abort("Must supply an API key. See the docs on where to store it.",
                   call = parent.frame())
  }
  # prep params
  max_yrs <- 10
  years <- seq(startyear, endyear, by = 1)
  if (length(years) >= max_yrs) {
    cli::cli_alert_info("The API can only get {max_yrs} years of data at once; making multiple calls, but this might take a little longer.")
  }
  years <- split_n(years, max_yrs)

  # make api query, call in main function
  base_url <- "https://api.bls.gov/publicAPI/v2/timeseries/data"
  params <- make_cpi_query(series, years, key)
  params <- purrr::map(params, function(p) list(url = base_url, body = p))
  params
}

make_cpi_query <- function(series, years, key) {
  purrr::map(years, function(yr) {
    startyear <- min(yr); endyear <- max(yr)
    list(seriesid = I(series),
         startyear = startyear,
         endyear = endyear,
         calculations = FALSE,
         registrationKey = key)
  })
}

#' @export
adj_inflation <- function(data, value, year, base_year = 2019, series = c("CUSR0000SA0", "CUUR0000AA0", "CUUR0000SA0"), verbose = FALSE, key = NULL) {
  series <- rlang::arg_match(series)
  yr_lbl <- rlang::as_label(rlang::enquo(year))

  yr_range <- range(dplyr::pull(data, year))
  startyear <- min(c(yr_range[1], base_year))
  endyear <- max(c(yr_range[2], base_year))

  query <- cpi_prep(series, startyear, endyear, key)
  agent <- httr::user_agent("cwi")
  fetch <- purrr::map(query, function(q) {
    httr::POST(q$url, body = q$body, encode = "json", agent, httr::timeout(20))
  })
  fetch <- purrr::map(fetch, httr::content, as = "text", encoding = "utf-8")
  fetch <- purrr::map(fetch, jsonlite::fromJSON)
  fetch <- purrr::map(fetch, purrr::pluck, "Results", "series")
  fetch <- purrr::map_dfr(fetch, dplyr::as_tibble)
  fetch <- tidyr::unnest(fetch, data)
  fetch <- dplyr::mutate(fetch, dplyr::across(c(year, value), as.numeric))
  fetch <- dplyr::group_by(fetch, year)
  fetch <- dplyr::summarise(fetch, avg_cpi = mean(value))
  fetch <- dplyr::ungroup(fetch)
  fetch <- dplyr::mutate(fetch, adj_factor = round(avg_cpi / avg_cpi[year == base_year], digits = 3))
  fetch <- dplyr::select(fetch, year, adj_factor)

  adjusted <- dplyr::mutate(data, dplyr::across({{ year }}, as.numeric))
  adjusted <- dplyr::left_join(adjusted, fetch, by = stats::setNames("year", yr_lbl))
  adjusted <- dplyr::mutate(adjusted, dplyr::across({{ value }}, list(adj = ~. / adj_factor), .names = "{.fn}_{.col}"))
  adjusted
}
