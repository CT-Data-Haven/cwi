############# GET CLEAN VARIABLE NAMES
# get decennial vars by year, cached
clean_decennial_vars <- function(year, sumfile = "sf1") {
  tidycensus::load_variables(year = year, sumfile, cache = T) %>%
    dplyr::filter(stringr::str_detect(name, "^(H|P|HCT|PCO|PCT)\\d+"))
}

############# CHECK AVAILABILITY OF TABLE
# call clean_acs_vars, grep table number, return number & concept
# use regex from making decennial_nums
decennial_available <- function(tbl, year, sumfile) {
  decennial_vars <- clean_decennial_vars(year, sumfile)
  avail <- decennial_vars %>%
    dplyr::select(-label) %>%
    dplyr::mutate(table = stringr::str_extract(name, "^(H|P|HCT|PCT|PCO)\\d{3}[A-Z]?")) %>%
    dplyr::select(table, concept) %>%
    unique() %>%
    dplyr::filter(table == tbl)
  # is_avail <- nrow(avail) > 0
  # assertthat::assert_that(is_avail, msg = stringr::str_glue("Table {tbl} for {year} {sumfile} is not available in the API."))
  # is_avail
  list(is_avail = nrow(avail) > 0, table = avail[["table"]], concept = avail[["concept"]])
}


#' Quickly add the labels of decennial variables
#'
#' `tidycensus::get_decennial` returns a decennial data table with its variable codes, which can be joined with `cwi::decennial_vars10` to get readable labels. This function is just a quick wrapper around the common task of joining these two data frames.
#' @param .data A data frame/tibble.
#' @param year The year of decennial census data; defaults 2010.
#' @param sumfile A string: which summary file to use. Defaults to the 100 percent summary file (`"sf1"`), but can also be `"sf3"`.
#' @param variable The bare column name of variable codes; defaults to `variable`, as returned by `tidycensus::get_decennial`.
#' @return A tibble
#' @seealso [decennial_vars10]
#' @export
label_decennial <- function(.data, year = 2010, sumfile = "sf1", variable = variable) {
  variable_var <- rlang::enquo(variable)
  variable_name <- rlang::as_label(variable_var)
  dec_vars <- clean_decennial_vars(year = year, sumfile = sumfile)
  .data %>%
    dplyr::left_join(dec_vars %>% dplyr::select(-concept), by = stats::setNames("name", variable_name))
}
