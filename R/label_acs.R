#' Quickly add the labels of ACS variables
#'
#' `tidycensus::get_acs` returns an ACS table with its variable codes, which can be joined with `cwi::acs_vars` to get readable labels. This function is just a quick wrapper around the common task of joining these two data frames.
#' @param df A data frame/tibble.
#' @param variable The bare column name of variable codes; defaults to `variable`, as returned by `get_acs`.
#' @return A tibble
#' @seealso [acs_vars]
#' @export
label_acs <- function(df, variable = variable) {
  variable_var <- rlang::enquo(variable)
  variable_name <- rlang::quo_name(variable_var)
  df %>%
    dplyr::left_join(acs_vars %>% dplyr::select(-concept), by = stats::setNames("name", variable_name))
}
