#' Clean up town names as returned from ACS
#' @param data A data frame
#' @param name_col Bare column name of town names
#' @return A tibble/data frame with cleaned names and "not defined" towns removed
#' @export
town_names <- function(data, name_col) {
  data <- dplyr::mutate(data, {{ name_col }} := stringr::str_extract({{ name_col }}, "^.+(?= town)"))
  data <- dplyr::filter(data, !grepl("not defined", {{ name_col }}) & !is.na({{ name_col }}))
  data
}
