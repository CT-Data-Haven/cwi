# dynamically check availability of:
# * qwi by state (prev qwi_avail)
# * census available (prev cb_avail)
# use caching & memoization with cachem & memoise

## CENSUS BUREAU: DATASETS IN THE API BY PROGRAM ----

#' @title Check availability of datasets
#' @description These two functions check for the availability of datasets needed
#' to formulate API queries.
#' * `check_cb_avail` finds all available vintages of
#' major surveys under the Census Bureau's ACS and Decennial programs for the
#' mainland US.
#' * `check_qwi_avail` finds all years of QWI data available per state.
#'
#' Previously, these were datasets built into the package, which ran the risk of
#' being outdated and therefore missing the availability of new data. These functions
#' need to read data from the internet, but are memoized so that the results are
#' reasonably up-to-date without having to make API calls repeatedly.
#' @return **For `check_cb_avail`**: A data frame with columns for vintage, program (e.g. "acs"), survey (e.g. "acs5"),
#' and title, as returned from the Census Bureau API.
#' @examples
#' \dontrun{
#' if (interactive()) {
#'     cb_avail <- check_cb_avail()
#'     cb_avail |>
#'         dplyr::filter(program == "dec", vintage == 2020)
#' }
#' }
#' @export
#' @seealso [US Census Bureau API Discovery Tool](https://www.census.gov/data/developers/updates/new-discovery-tool.html) [LED Extraction Tool](https://ledextract.ces.census.gov/)
#' @rdname availability
#' @family utils
check_cb_avail <- function() {
    # ALL TABLES AVAILABLE: VINTAGE + PROGRAM + SURVEY CODE
    surveys <- list(
        acs = c("acs1", "acs3", "acs5"),
        dec = c(
            "ddhca", "ddhcb", "dhc", "pl",
            "sf1", "sf2", "sf3", "sf4"
        )
    )
    surveys <- tibble::enframe(surveys, name = "program", value = "survey")
    surveys <- tidyr::unnest(surveys, survey)

    avail <- safe_read_avail("https://api.census.gov/data.json", "json")
    avail <- avail[["dataset"]]
    avail <- purrr::map(avail, cb_meta_list)
    avail <- purrr::compact(avail)
    avail <- dplyr::bind_rows(avail)
    avail <- tidyr::unnest_wider(avail, dataset, names_sep = "", names_repair = "unique")
    # drop survey subsets
    avail <- avail[is.na(avail$dataset3), ]
    avail <- dplyr::select(avail, vintage, program = dataset1, survey = dataset2, title)
    avail <- dplyr::semi_join(avail, surveys, by = c("program", "survey"))
    avail <- dplyr::arrange(avail, vintage, program, survey)
    avail
}

cb_meta_list <- function(x) {
    list(
        vintage = x$c_vintage,
        dataset = list(x$c_dataset),
        title = x$title
    )
}

## QWI: STATES + YEARS AVAILABLE ----
#' @return **For check_qwi_avail`**: A data frame with columns for state FIPS code, earliest year available, and most recent year available.
#' @examples
#' \dontrun{
#' if (interactive()) {
#'     qwi_avail <- check_qwi_avail()
#'     qwi_avail |>
#'         dplyr::filter(state_code == "09")
#' }
#' }
#' @export
#' @rdname availability
check_qwi_avail <- function() {
    # scrape start & end years per state from html table
    # get fips code instead of state abbrevs
    avail <- safe_read_avail("https://ledextract.ces.census.gov/loading_status.html", "html")
    avail <- rvest::html_table(avail)[[1]]
    avail <- janitor::clean_names(avail)
    avail <- dplyr::mutate(avail, dplyr::across(c(start_quarter, end_quarter), function(x) {
        x <- stringr::str_extract(x, "\\d{4}")
        as.numeric(x)
    }))
    states <- dplyr::distinct(tidycensus::fips_codes, state, state_code)
    avail <- dplyr::inner_join(avail, states, by = "state")
    avail <- dplyr::select(avail, state_code, start_year = start_quarter, end_year = end_quarter)
    avail <- dplyr::arrange(avail, state_code)
    avail
}

safe_read_avail <- function(url, type) {
    if (type == "json") {
        func <- jsonlite::read_json
    } else if (type == "html") {
        func <- rvest::read_html
    } else {
        cli::cli_abort("Incorrect file type")
    }
    safe_func <- purrr::safely(func)
    res <- safe_func(url)
    if (is.null(res$error)) {
        res$result
    } else {
        cli::cli_abort("Unable to get available data from {.url {url}}. Check the Census API.")
    }
}
