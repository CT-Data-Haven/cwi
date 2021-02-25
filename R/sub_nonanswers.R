#' @title Remove non-answers and rescale percentage values
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This is a convenience function for removing what might be
#' considered non-answers ("don't know", "refused", etc.) and rescaling the
#' remaining values to add to 1.0.
#' @param .data A data frame
#' @param response Bare column name of where responses are found, including
#' those considered to be non-answers. Default: response
#' @param value Bare column name of values, Default: value
#' @param nons Character vector of responses to be removed.
#' Default: c("Don't know", "Refused")
#' @param factor_response Logical: if `TRUE` (default), returns response variable
#' as a factor. This is likely a more useful way to handle response
#' categories once non-answers have been removed.
#' @return A data frame with the same number of columns as the original, but
#' fewer rows
#' @examples
#' if (interactive()) {
#' xt <- system.file("extdata/test_xtab2018.xlsx", package = "cwi")
#' df <- read_xtabs(xt, process = TRUE) %>%
#'   dplyr::filter(code == "Q1") %>%
#'   sub_nonanswers()
#' }
#' @export
#' @rdname sub_nonanswers

sub_nonanswers <- function(.data, response = response, value = value, nons = c("Don't know", "Refused"), factor_response = TRUE) {
  # warn if any nons aren't actually in the data
  response_vals <- .data %>%
    dplyr::pull({{ response }}) %>%
    unique()
  xtra_nons <- setdiff(nons, response_vals)
  if (length(xtra_nons) > 0) {
    warning("Your value of 'nons' contains responses not found in the data:\n",
            paste(xtra_nons, collapse = ", "), " not found.")
  }

  if (any(dplyr::pull(.data, {{ value }}) > 1.0)) {
    warning("Your data contains values greater than 1.0. This function is designed for percentage data, so you'll probably get values that don't actually make sense.")
  }
  # add up values of nonanswers, use 1 - sum(nons) as denom
  responses <- response_vals %>%
    setdiff(nons) %>%
    rlang::syms()

  grps <- dplyr::groups(.data)

  wide <- .data %>%
    dplyr::ungroup() %>%
    tidyr::pivot_wider(names_from = {{ response }}, values_from = {{ value }})

  non_sum <- wide %>%
    dplyr::select(dplyr::any_of(nons)) %>%
    rowSums()
  out <- wide %>%
    dplyr::mutate(non_sum = non_sum)
  out <- out %>%
    dplyr::mutate(dplyr::across(c(!!!responses), ~. / (1 - non_sum)))
  out <- out %>%
    dplyr::select(-non_sum, -dplyr::any_of(nons)) %>%
    tidyr::pivot_longer(c(!!!responses),
                        names_to = rlang::as_string(quote(response)), values_to = rlang::as_string(quote(value))) %>%
    dplyr::group_by(!!!grps)
  if (factor_response) {
    dplyr::mutate(out, dplyr::across({{ response }}, forcats::as_factor))
  }
}
