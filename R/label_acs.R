# get acs variables by year, cached
clean_acs_vars <- function(year) {
  tidycensus::load_variables(year = year, "acs5", cache = T) %>%
    dplyr::filter(stringr::str_detect(name, "_\\d{3}E$")) %>%
    dplyr::mutate(label = stringr::str_remove(label, "Estimate!!")) %>%
    dplyr::mutate(label = stringr::str_remove_all(label, ":")) %>%
    dplyr::mutate(name = stringr::str_remove(name, "E$"))
}

# get decennial vars by year, cached
clean_decennial_vars <- function(year) {
  tidycensus::load_variables(year = year, "sf1", cache = T) %>%
    dplyr::filter(stringr::str_detect(name, "^(H|P|HCT|PCO|PCT)\\d+"))
}

#' Quickly add the labels of ACS variables
#'
#' `tidycensus::get_acs` returns an ACS table with its variable codes, which can be joined with `cwi::acs_vars` to get readable labels. This function is just a quick wrapper around the common task of joining these two data frames.
#' @param df A data frame/tibble.
#' @param year The endyear of ACS data; defaults 2016.
#' @param variable The bare column name of variable codes; defaults to `variable`, as returned by `tidycensus::get_acs`.
#' @return A tibble
#' @seealso [acs_vars]
#' @export
label_acs <- function(df, year = 2016, variable = variable) {
  variable_var <- rlang::enquo(variable)
  variable_name <- rlang::quo_name(variable_var)
  acs_vars <- clean_acs_vars(year = year)
  df %>%
    dplyr::left_join(acs_vars %>% dplyr::select(-concept), by = stats::setNames("name", variable_name))
}
