############# GET CLEAN VARIABLE NAMES
# get acs variables by year, cached
clean_acs_vars <- function(year, survey = "acs5") {
  tidycensus::load_variables(year = year, survey, cache = T) %>%
    dplyr::filter(stringr::str_detect(name, "_\\d{3}E?$")) %>%
    dplyr::mutate(label = stringr::str_remove(label, "Estimate!!")) %>%
    dplyr::mutate(label = stringr::str_remove_all(label, ":")) %>%
    dplyr::mutate(name = stringr::str_remove(name, "E$"))
}


############# CHECK AVAILABILITY OF TABLE
# call clean_acs_vars, grep table number, return number & concept
acs_available <- function(tbl, year, survey) {
  acs_vars <- clean_acs_vars(year, survey)
  avail <- acs_vars %>%
    dplyr::select(-label) %>%
    dplyr::mutate(table = stringr::str_extract(name, "^[BC]\\d+[[:upper:]]?(?=_)")) %>%
    dplyr::select(table, concept) %>%
    unique() %>%
    dplyr::filter(table == tbl)
  # is_avail <- nrow(avail) > 0
  # assertthat::assert_that(is_avail, msg = stringr::str_glue("Table {tbl} for {year} {survey} is not available in the API."))
  # is_avail
  list(is_avail = nrow(avail) > 0, table = avail[["table"]], concept = avail[["concept"]])
}


#' Quickly add the labels of ACS variables
#'
#' `tidycensus::get_acs` returns an ACS table with its variable codes, which can be joined with `cwi::acs_vars18` to get readable labels. This function is just a quick wrapper around the common task of joining these two data frames.
#' @param df A data frame/tibble.
#' @param year The endyear of ACS data; defaults 2018.
#' @param survey A string: which ACS estimate to use. Defaults to 5-year (`"acs5"`), but can also be 1-year (`"acs1"`) or 3-year (`"acs3"`), though both 1-year and 3-year have limited availability.
#' @param variable The bare column name of variable codes; defaults to `variable`, as returned by `tidycensus::get_acs`.
#' @return A tibble
#' @seealso [acs_vars18]
#' @export
label_acs <- function(df, year = 2018, survey = "acs5", variable = variable) {
  variable_var <- rlang::enquo(variable)
  variable_name <- rlang::quo_name(variable_var)
  acs_vars <- clean_acs_vars(year = year, survey = survey)
  df %>%
    dplyr::left_join(acs_vars %>% dplyr::select(-concept), by = stats::setNames("name", variable_name))
}
