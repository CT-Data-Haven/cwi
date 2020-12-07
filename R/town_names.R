#' Clean up town names as returned from ACS
#' @param .data A data frame
#' @param name_col Bare column name of town names
#' @return A tibble/data frame with cleaned names and "not defined" towns removed
#' @export
town_names <- function(.data, name_col) {
  name_var <- rlang::enquo(name_col)
  .data %>%
    dplyr::mutate({{ name_var }} := stringr::str_extract({{ name_var }}, "^.+(?= town)")) %>%
    dplyr::filter(!stringr::str_detect({{ name_var }}, "not defined"))
}
