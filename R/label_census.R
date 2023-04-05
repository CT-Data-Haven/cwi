############# LABEL DATA TABLES ----
#' Quickly add the labels of decennial variables
#'
#' `tidycensus::get_decennial` returns a decennial data table with its variable codes, which can be joined with `cwi::decennial_vars10` to get readable labels. This function is just a quick wrapper around the common task of joining these two data frames.
#' @param data A data frame/tibble.
#' @param year The year of decennial census data; defaults 2010.
#' @param sumfile A string: which summary file to use. Defaults to the 100 percent summary file (`"sf1"`), but can also be `"sf3"`.
#' @param variable The bare column name of variable codes; defaults to `variable`, as returned by `tidycensus::get_decennial`.
#' @return A tibble
#' @seealso [decennial_vars10]
#' @export
label_decennial <- function(data, year = 2010, sumfile = "sf1", variable = variable) {
  variable_lbl <- rlang::as_label(rlang::enquo(variable))
  dec_vars <- clean_decennial_vars(year = year, sumfile = sumfile)
  dec_vars <- dplyr::select(dec_vars, name, label)
  vars_out <- dplyr::left_join(data, dec_vars, by = stats::setNames("name", variable_lbl))
  vars_out
}

#' Quickly add the labels of ACS variables
#'
#' `tidycensus::get_acs` returns an ACS table with its variable codes, which can be joined with `cwi::acs_vars*` to get readable labels. This function is just a quick wrapper around the common task of joining these two data frames.
#' @param data A data frame/tibble.
#' @param year The endyear of ACS data; defaults 2021.
#' @param survey A string: which ACS estimate to use. Defaults to 5-year (`"acs5"`), but can also be 1-year (`"acs1"`) or 3-year (`"acs3"`), though both 1-year and 3-year have limited availability.
#' @param variable The bare column name of variable codes; defaults to `variable`, as returned by `tidycensus::get_acs`.
#' @return A tibble
#' @seealso [acs_vars21]
#' @export
label_acs <- function(data, year = 2021, survey = "acs5", variable = variable) {
  variable_lbl <- rlang::as_label(rlang::enquo(variable))
  acs_vars <- clean_acs_vars(year = year, survey = survey)
  acs_vars <- dplyr::select(acs_vars, name, label)
  vars_out <- dplyr::left_join(data, acs_vars, by = stats::setNames("name", variable_lbl))
  vars_out
}

#################### HELPERS ##########################################
############# CHECK TABLE AVAILABILITY ----
# call clean_*_vars, grep table number, return number & concept or false
table_available <- function(src, tbl, year, dataset) {
  # regex used to extract table numbers
  if (src == "acs") {
    all_vars <- clean_acs_vars(year, dataset)
    patt <- "^[BC]\\d+[[:upper:]]*(?=_)"
  } else {
    all_vars <- clean_decennial_vars(year, dataset)
    patt <- "^(H|P|HCT|PCT|PCO)\\d{1,3}[A-Z]?" # switch from \\d{3} to deal with pl tables
  }
  all_vars$table <- stringr::str_extract(all_vars$name, patt)
  all_vars <- dplyr::distinct(all_vars, table, concept)
  avail <- all_vars[all_vars$table == tbl & !is.na(all_vars$table), ]

  if (nrow(avail) == 0) {
    return(FALSE)
  } else {
    return(c(as.list(avail), list(year = year)))
  }
}

# not actually using this rn
pad_table <- function(table) {
  num <- as.numeric(stringr::str_extract(table, "\\d+"))
  lett <- stringr::str_extract(table, "^[A-Z]")
  sprintf("%s%03d", lett, num)
}


############# GET CLEAN VARIABLE NAMES ----
# get decennial vars by year, cached
clean_decennial_vars <- function(year, sumfile) {
  dec_vars <- tidycensus::load_variables(year = year, dataset = sumfile, cache = TRUE)
  dec_vars <- dplyr::filter(dec_vars, grepl("^(H|P|HCT|PCO|PCT)\\d+", name))
  dec_vars$label <- stringr::str_remove(dec_vars$label, "^ !!")
  dec_vars$label <- stringr::str_remove_all(dec_vars$label, ":")
  dec_vars
}

# get acs variables by year, cached
clean_acs_vars <- function(year, survey) {
  acs_vars <- tidycensus::load_variables(year = year, dataset = survey, cache = TRUE)
  acs_vars <- dplyr::filter(acs_vars, grepl("_\\d{3}E?$", name))
  acs_vars$label <- stringr::str_remove(acs_vars$label, "Estimate!!")
  acs_vars$label <- stringr::str_remove_all(acs_vars$label, ":")
  acs_vars$name <- stringr::str_remove(acs_vars$name, "E$")
  acs_vars <- acs_vars[, c("name", "label", "concept")]
  acs_vars
}


