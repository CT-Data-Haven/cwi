#' Clean up town names as returned from ACS
#'
#' This function does two things: it removes text other than the town name from the column given as `name_col`, and it removes any rows for "county subdivisions not defined." For example, the string "Ansonia town, New Haven County, Connecticut" will become "Ansonia."
#' @param data A data frame
#' @param name_col Bare column name of town names
#' @return A tibble/data frame with cleaned names and "not defined" towns removed
#' @examples
#' pops <- tibble::tribble(
#'     ~name, ~total_pop,
#'     "County subdivisions not defined, New Haven County, Connecticut", 0,
#'     "Ansonia town, New Haven County, Connecticut", 18802,
#'     "Beacon Falls town, New Haven County, Connecticut", 6168,
#'     "Bethany town, New Haven County, Connecticut", 5513,
#'     "Branford town, New Haven County, Connecticut", 2802
#' )
#' town_names(pops, name_col = name)
#' @family utils
#' @export
town_names <- function(data, name_col) {
    data <- dplyr::mutate(data, {{ name_col }} := stringr::str_extract({{ name_col }}, "^.+(?= town)"))
    data <- dplyr::filter(data, !grepl("not defined", {{ name_col }}) & !is.na({{ name_col }}))
    data
}
