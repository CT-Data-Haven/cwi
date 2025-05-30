#' @title Collapse survey groups and get weighted means
#' @description
#' `r lifecycle::badge("deprecated")` **Deprecation notice:** Crosstab-related
#' functions have been moved from cwi to the dcws package. The versions here will be
#' removed soon.
#' This is just a quick wrapper for a common, tedious task of
#' collapsing several demographic groups, such as income brackets, into
#' larger groups and taking a weighted mean based on a set of survey weights.
#' @param data A data frame, such as returned by [dcws::xtab2df()] joined with
#' survey weights as returned by [dcws::read_weights()]. The default
#' column names here match those returned by `xtab2df` (`group`, `value`) and
#' `read_weights` (`weight`).
#' @param ... Bare column names to use for grouping, including the `.group` column,
#' such as location, year, category, response, etc--probably everything except
#' values and weights.
#' @param .lvls A named list, where values are character vectors of smaller
#' groups (e.g. `c("<$15K", "$15K-$30K")`) and names are the groups those will
#' be replaced by (e.g. `"<$30K"`). This will be split into the arguments to
#' [forcats::fct_collapse()].
#' @param .group Bare column name of where groups should be found. Default: group
#' @param .value Bare column name of where values should be found. Default: value
#' @param .weight Bare column name of where group weights should be found. Default: weight
#' @param .fill_wts Logical: if `TRUE`, missing weights will be filled in with 1,
#' i.e. unweighted. This defaults to `FALSE`, because missing weights is a
#' useful way to find that there's a mismatch between the group labels in
#' the data and those in the weights table, which is very often the case.
#' Therefore, only set this to `TRUE` if you've already accounted for labeling
#' discrepancies.
#' @param .digits Numeric: if given, weighted means will be rounded to this
#' number of digits. If `NULL` (the default), values are returned unrounded.
#' @return A data frame with summarized values. The `.group` column will have
#' the collapsed groups, and the `.value` column will have average values.
#' @export
#' @keywords internal dcws-migration
#' @seealso [dcws::collapse_n_wt()] [dcws::xtab2df()] [dcws::read_weights()] [forcats::fct_collapse()]
collapse_n_wt <- function(data,
                          ...,
                          .lvls,
                          .group = group,
                          .value = value,
                          .weight = weight,
                          .fill_wts = FALSE,
                          .digits = NULL) {
    deprecation_msg("collapse_n_wt", "1.12.1", "dcws", id = "dcws-collapse")
    group_cols <- rlang::quos(...)
    to_wt <- dplyr::ungroup(data)
    to_wt <- dplyr::mutate(to_wt, dplyr::across({{ .group }}, \(x) forcats::fct_collapse(x, !!!.lvls)))
    to_wt <- dplyr::group_by(to_wt, dplyr::across(!!!group_cols))

    if (.fill_wts) {
        cli::cli_alert_info("Missing values in your weights column are being filled in. Make sure this is intentional!")
        to_wt <- dplyr::mutate(to_wt, dplyr::across({{ .weight }}, \(x) tidyr::replace_na(x, 1)))
    }
    out <- dplyr::summarise(to_wt, {{ .value }} := stats::weighted.mean({{ .value }}, w = {{ .weight }}))

    if (is.numeric(.digits)) {
        out <- dplyr::mutate(out, {{ .value }} := round({{ .value }}, digits = .digits))
    }
    dplyr::ungroup(out)
}
