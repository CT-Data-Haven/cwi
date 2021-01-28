read_xtabs_ <- function(path, name_prefix) {
  readxl::read_excel(path, col_names = FALSE, .name_repair = make.names) %>%
    rlang::set_names(function(n) paste0(name_prefix, 1:ncol(.))) %>%
    janitor::remove_empty(which = "rows")
}

#' @title Read crosstab data and weights
#' @description These two functions facilitate reading in Excel
#' spreadsheets of crosstabs generated from SPSS. Note that they're likely
#' only useful for working with the DataHaven Community Wellbeing Survey.
#' @param path Path to an excel file
#' @param name_prefix String used to create column names such as x1, x2, x3, ...,
#' Default: 'x'
#' @param marker String/regex pattern used to demarcate crosstabs from weight
#' table. If `NULL`, it will be assumed that the file contains only crosstab
#' data *or* weights, and no filtering will be done.
#' Default: `"Nature of the [Ss]ample"`
#' @param year Numeric. As of now, its main purpose is to add an extra filtering
#' step to take out headers in the 2015 files. Default: 2018
#' @param process Logical: if `FALSE` (the default), this will return the
#' crosstab data to be processed, most likely by passing along to `xtab2df`. If
#' `TRUE`, `xtab2df` will be called, and you'll receive a nice, clean data frame
#' ready for analysis. This is *only* recommended if you already know for sure
#' what the crosstab data looks like, so you don't accidentally lose some
#' questions or important description. As a sanity check, you'll see a message
#' listing the parameters used in the `xtab2df` call.
#' @param ... Additional arguments passed on to `xtab2df` if `process = TRUE`.
#' @return A data frame. For `read_xtabs`, there will be one column per
#' demographic/geographic group included, plus one for the questions & answers.
#' For `read_weights`, only 2 columns, one for demographic groups and one for
#' their associated weights.
#' @examples
#' if(interactive()) {
#'   xt <- system.file("inst/extdata/test_xtab2018.xlsx", package = "cwi")
#'   read_weights(xt)
#'
#'   # returns a not-very-pretty data frame of the crosstabs to be processed
#'   read_xtabs(xt)
#'   # returns a pretty data frame ready for analysis
#'   read_xtabs(xt, process = TRUE)
#' }
#' @export
#' @rdname read_xtabs
#' @seealso [cwi::xtab2df()]
read_xtabs <- function(path, name_prefix = "x", marker = "Nature of the [Ss]ample", year = 2018, process = FALSE, ...) {
  data <- read_xtabs_(path, name_prefix)
  first_col <- rlang::sym(names(data)[1])
  if (year == 2015) {
    data <- camiller::filter_after(data, grepl("Sample Size", x1))
  }
  data <- dplyr::filter(data, !stringr::str_detect({{ first_col }}, "Weighted [Tt]otal") | is.na({{ first_col }}))
  if (!is.null(marker)) {
    data <- camiller::filter_until(data, grepl(marker, {{ first_col }}))
  }
  if (process) {
    xt_params(...)
    xtab2df(data, ...)
  } else {
    data
  }
}

#' @export
#' @rdname read_xtabs
read_weights <- function(path, marker = "Nature of the [Ss]ample") {
  data <- read_xtabs_(path, name_prefix = "x")
  first_col <- rlang::sym(names(data)[1])
  if (!is.null(marker)) {
    data <- data %>%
      camiller::filter_after(grepl(marker, {{ first_col }}))
  }
  data %>%
    janitor::remove_empty(which = "cols") %>%
    dplyr::select(group = 1, weight = 2) %>%
    dplyr::filter(!is.na(weight)) %>%
    dplyr::mutate(weight = round(as.numeric(weight), digits = 3))
}

xt_params <- function(...) {
  defaults <- formals(xtab2df)
  user <- rlang::list2(...)
  # don't need to include .data
  from_def <- defaults[!names(defaults) %in% names(user)][-1]
  params <- c(from_def, user)
  params <- params[names(defaults)[-1]]
  param_str <- paste(names(params), params, sep = " = ", collapse = ", ")
  message("xtab2df is being called on the data with the parameters ", param_str)
}
