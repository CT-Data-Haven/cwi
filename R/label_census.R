############# LABEL DATA TABLES ----
#' @title Quickly add the labels of census variables
#' @description `multi_geo_*` functions, and their underlying `tidycensus::get_*` functions, return data tables with variable codes (e.g. "B01001_003"), which can be joined with lookup tables to get readable labels (e.g. "Total!!Male!!Under 5 years"). These functions are just quick wrappers around the common task of joining your data frame with the variable codes and labels.
#' @param data A data frame/tibble.
#' @param year The year of data; defaults to `r cwi:::endyears[["acs"]]` for ACS, or `r cwi:::endyears[["decennial"]]` for decennial.
#' @param variable The bare column name of variable codes; defaults to `variable`, as returned by the `multi_geo_*` or `tidycensus::get_*` functions.
#' @param sumfile For `label_decennial`, a string: which summary file to use. Defaults to `"dhc"`, the code used for 2020. 2010 used summary files labeled `"sf1"` or `"sf3"`.
#' @return A tibble with the same number of rows as `data` but an additional column called `label`
#' @seealso [decennial_vars] [acs_vars]
#' @family augmenting-functions
#' @export
#' @rdname label_census
label_decennial <- function(data, year = 2020, sumfile = "dhc", variable = variable) {
    variable_lbl <- rlang::as_label(rlang::enquo(variable))
    dec_vars <- clean_decennial_vars(year = year, sumfile = sumfile)
    dec_vars <- dplyr::select(dec_vars, name, label)
    vars_out <- dplyr::left_join(data, dec_vars, by = stats::setNames("name", variable_lbl))

    if (any(is.na(vars_out[["label"]]))) {
        cli::cli_warn(c("Not all variables matched with decennial census labels.",
                        i = "Check that you have the correct year and sumfile, and that this is proper decennial data."))
    }
    vars_out
}

#' @param survey For `label_acs`, a string: which ACS estimate to use. Defaults to 5-year (`"acs5"`), but can also be 1-year (`"acs1"`) or 3-year (`"acs3"`), though both 1-year and 3-year have limited availability.
#' @examples
#' \dontrun{
#'   acs_pops <- multi_geo_acs("B01001")
#'   label_acs(acs_pops)
#' }
#' @family augmenting-functions
#' @export
#' @rdname label_census
label_acs <- function(data, year = 2023, survey = "acs5", variable = variable) {
    variable_lbl <- rlang::as_label(rlang::enquo(variable))
    acs_vars <- clean_acs_vars(year = year, survey = survey)
    acs_vars <- dplyr::select(acs_vars, name, label)
    vars_out <- dplyr::left_join(data, acs_vars, by = stats::setNames("name", variable_lbl))

    if (any(is.na(vars_out[["label"]]))) {
        cli::cli_warn(c("Not all variables matched with ACS labels.",
                        i = "Check that you have the correct year and survey, and that this is proper ACS data."))
    }
    vars_out
}

#################### HELPERS ##########################################
############# CHECK TABLE AVAILABILITY ----
# call clean_*_vars, grep table number, return number & concept or false
table_available <- function(src, tbl, year, dataset) {
    # regex used to extract table numbers
    if (src == "acs") {
        all_vars <- clean_acs_vars(year, dataset)
        patt <- "^[BC]\\d+[A-Z]*(?=_)"
    } else if (src == "decennial") {
        all_vars <- clean_decennial_vars(year, dataset)

        if (year < 2020) {
            patt <- "^(H|P|HCT|PCT|PCO)\\d{3}[A-Z]?"
        } else {
            patt <- "(^[A-Z0-9]+)"
        }
    } else {
        return(FALSE)
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
dataset_available <- function(src, year, dataset) {
    if (src == "decennial") {
        src <- "dec"
    }
    # cache results of checking cb availability
    # mem_check_cb <- memoise::memoise(check_cb_avail, cache = prep_cache())
    cb_avail <- check_cb_avail()
    avail <- cb_avail[cb_avail$vintage == year & cb_avail$program == src & cb_avail$survey == dataset, ]
    if (nrow(avail) == 0) {
        return(FALSE)
    } else {
        return(as.list(avail))
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
