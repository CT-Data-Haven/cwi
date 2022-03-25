fetch_bls <- function(query, verbose) {
  # query is a list of api body
  # send POST with retry
  # if verbose, print heading
  # return df of seriesID, data
  agent <- httr::user_agent("cwi")

  fetch <- purrr::map(query, function(q) {
    resp <- httr::RETRY("POST", q$url, body = q$body, encode = "json", agent, retry = 3)
    if (httr::http_error(resp)) {
      cli::cli_abort(c("An error occurred in making one or more API calls.",
                       "x" = httr::http_status(resp)[["message"]]),
                     call = parent.frame(n = 3))
    }
    resp
  })
  fetch <- purrr::map(fetch, httr::content, as = "text", encoding = "utf-8")
  fetch <- purrr::map(fetch, jsonlite::fromJSON)
  fetch <- purrr::map(fetch, purrr::pluck, "Results", "series")
  # json has object of seriesID, array of data, may/may not have object of catalog

  # print catalog info before dropping
  if (verbose) {
    bls_series_printout(fetch[[1]])
  }

  fetch <- purrr::map(fetch, function(x) x[c("seriesID", "data")])
  fetch <- purrr::map_dfr(fetch, dplyr::as_tibble)
  fetch <- tidyr::unnest(fetch, data)
  fetch
}
