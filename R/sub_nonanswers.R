#' @title Remove non-answers and rescale percentage values
#' @description
#' `r lifecycle::badge("deprecated")` **Deprecation notice:** Crosstab-related
#' functions have been moved from cwi to the dcws package. The versions here will be
#' removed soon. This is a convenience function for removing what might be
#' considered non-answers ("don't know", "refused", etc.) and rescaling the
#' remaining values to add to 1.0.
#' @param data A data frame
#' @param response Bare column name of where responses are found, including
#' those considered to be non-answers. Default: response
#' @param value Bare column name of values, Default: value
#' @param nons Character vector of responses to be removed.
#' Default: c("Don't know", "Refused")
#' @param factor_response Logical: if `TRUE` (default), returns response variable
#' as a factor. This is likely a more useful way to handle response
#' categories once non-answers have been removed.
#' @param rescale Logical: if `TRUE`, values will be scaled based on their total. If `FALSE` (the default), values are scaled based on an assumption that all responses add to 1. In some cases, crosstabs with heavy rounding might not add up to 1 when they should, so rescaling helps handle that.
#' @return A data frame with the same number of columns as the original, but
#' fewer rows
#' @examples
#' if (interactive()) {
#'     xt <- system.file("extdata/test_xtab2018.xlsx", package = "cwi")
#'     df <- read_xtabs(xt, process = TRUE) |>
#'         dplyr::filter(code == "Q1") |>
#'         sub_nonanswers()
#' }
#' @export
#' @keywords dcws-migration internal
#' @seealso [dcws::sub_nonanswers()]

sub_nonanswers <- function(data,
                           response = response,
                           value = value,
                           nons = c("Don't know", "Refused"),
                           factor_response = TRUE,
                           rescale = FALSE) {
    deprecation_msg("sub_nonanswers", "1.12.1", "dcws", id = "dcws-nonanswers")
    # warn if any nons aren't actually in the data
    response_vals <- unique(dplyr::pull(data, {{ response }}))
    xtra_nons <- setdiff(nons, response_vals)

    if (length(xtra_nons) > 0) {
        cli::cli_warn(c("!" = "Your value of {.var nons} contains responses not found in the data: {.val {xtra_nons}} not found."))
    }

    if (any(dplyr::pull(data, {{ value }}) > 1.0)) {
        cli::cli_warn(c(
            "!" = "Your data contains values greater than 1.0.",
            i = "This function is designed for percentage data, so you'll probably get values that don't actually make sense."
        ))
    }

    # add up values of nonanswers, use 1 - sum(nons) as denom
    # responses = real answers, i.e. not nons
    responses <- rlang::syms(setdiff(response_vals, nons))
    grps <- dplyr::groups(data)

    wide <- dplyr::ungroup(data)
    wide <- tidyr::pivot_wider(wide, names_from = {{ response }}, values_from = {{ value }})
    # non_sum <- rowSums(dplyr::select(wide, dplyr::any_of(nons)))
    wide$non_sum <- rowSums(dplyr::select(wide, dplyr::any_of(nons)))

    if (rescale) {
        total <- rowSums(dplyr::select(wide, dplyr::any_of(response_vals)))
    } else {
        total <- 1
    }

    wide <- dplyr::mutate(wide, dplyr::across(c(!!!responses), ~ .x / (total - non_sum)))
    wide <- dplyr::select(wide, -non_sum, -dplyr::any_of(nons))

    out <- tidyr::pivot_longer(wide,
        cols = c(!!!responses),
        names_to = rlang::as_label(rlang::enquo(response)),
        values_to = rlang::as_label(rlang::enquo(value))
    )
    out <- dplyr::group_by(out, !!!grps)

    if (factor_response) {
        out <- dplyr::mutate(out, dplyr::across({{ response }}, forcats::as_factor))
    }

    out
}
