#' @title Collapse survey groups and get weighted means
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This is just a quick wrapper for a common, tedious task of
#' collapsing several demographic groups, such as income brackets, into
#' larger groups and taking a weighted mean based on a set of survey weights.
#' @param .data A data frame, such as returned by [cwi::xtab2df()] joined with
#' survey weights as returned by [cwi::read_weights()]. The default
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
#' @examples
#' # collapse income groups, such that <$15K, $15K-$30K become <$30K, etc
#' income_lvls <- list(
#'   "<$30K" = c("<$15K", "$15K-$30K"),
#'   "$30K-$100K" = c("$30K-$50K", "$50K-$75K", "$75K-$100K"),
#'   "$100K+" = c("$100K-$200K", "$200K+")
#' )
#' cws_demo %>%
#'   dplyr::filter(category %in% c("Greater New Haven", "Income")) %>%
#'   collapse_n_wt(code:response, .lvls = income_lvls, .digits = 2)
#' @export
#' @rdname collapse_n_wt
#' @seealso [cwi::xtab2df()], [cwi::read_weights()], [forcats::fct_collapse()]
collapse_n_wt <- function(.data, ..., .lvls, .group = group, .value = value, .weight = weight, .fill_wts = FALSE, .digits = NULL) {
  group_cols <- quos(...)
  to_wt <- .data %>%
    dplyr::ungroup() %>%
    dplyr::mutate({{ .group }} := forcats::fct_collapse({{ .group }}, !!!.lvls)) %>%
    dplyr::group_by(dplyr::across(!!!group_cols))

  if (.fill_wts) {
    message("HEADS UP: Missing values in your weights column are being filled in. Make sure this is intentional!")
    # to_wt <- tidyr::replace_na(to_wt, list({{ .weight }} := 1))
    to_wt <- to_wt %>%
      dplyr::mutate({{ .weight }} := tidyr::replace_na({{ .weight }}, 1))
  }
  out <- to_wt %>%
    dplyr::summarise({{ .value }} := stats::weighted.mean({{ .value }}, w = {{ .weight }}))

  if (is.numeric(.digits)) {
    out <- out %>%
      dplyr::mutate({{ .value }} := round({{ .value }}, digits = .digits))
  }
  dplyr::ungroup(out)
}
