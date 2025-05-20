#' @title Separate labels given to ACS data
#' @description This is a quick wrapper around [tidyr::separate()] written to match the standard formatting used for ACS variable labels. These generally take the form e.g. "Total!!Male!!5 to 9 years". This function will separate values by `"!!"` and optionally drop the resulting "Total" column, which is generally constant for the entire data frame.
#' @param data A data frame such as returned by [multi_geo_acs()] or [tidycensus::get_acs()].
#' @param col Bare column name where ACS labels are. Default: label
#' @param into Character vector of names of new variables. If `NULL` (the default), names will be assigned as "x1", "x2," etc. If you don't want to include the Total column, this character vector only needs to include the groups other than Total (see examples).
#' @param sep Character: separator between columns. Default: '!!'
#' @param drop_total Logical, whether to include the "Total" column that comes from separating ACS data. Default: FALSE
#' @param ... Any additional arguments to be passed on to [tidyr::separate()].
#' @inheritDotParams tidyr::separate -data -col -into -sep
#' @return A data frame
#' @examples
#' \dontrun{
#' if (interactive()) {
#'     age <- label_acs(multi_geo_acs("B01001"))
#'
#'     # Default: allow automatic labeling, in this case x1, x2, x3
#'     separate_acs(age)
#'
#'     # Drop Total column, use automatic labeling (x1 & x2)
#'     separate_acs(age, drop_total = TRUE)
#'
#'     # Keep Total column; assign names total, sex, age
#'     separate_acs(age, into = c("total", "sex", "age"))
#'
#'     # Drop Total column; only need to name sex & age
#'     separate_acs(age, into = c("sex", "age"), drop_total = TRUE)
#'
#'     # Carried over from tidyr::separate, using NA in place of the Total column
#'     # will also drop that column and yield the same as the previous example
#'     separate_acs(age, into = c(NA, "sex", "age"))
#' }
#' }
#' @keywords utils
#' @export
#' @seealso [tidyr::separate()]
separate_acs <- function(data, col = label, into = NULL, sep = "!!", drop_total = FALSE, ...) {
    # if into is null, create names x1, x2, etc
    if (is.null(into)) {
        ncol <- max(lengths(strsplit(data[[rlang::as_label(rlang::enquo(col))]], split = sep)))
        if (drop_total) {
            into <- c(NA, paste0("x", 1:(ncol - 1)))
        } else {
            into <- paste0("x", 1:ncol)
        }
    } else {
        if (drop_total) {
            # if there's an NA in into, don't change it
            if (!any(is.na(into))) {
                into <- c(NA, into)
            }
        }
    }

    tidyr::separate(data, col = {{ col }}, into = into, sep = sep, ...)
}
