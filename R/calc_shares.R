#' Make table of rates given a denominator
#'
#' `calc_shares` makes it easy to divide values by some denominator within the same long-shaped data frame. For example, it works well for a table of population groups for multiple locations where you want to divide population counts by some total population. It optionally handles dividing margins of error. Denote locations or other groupings by using a grouped data frame, passing bare column names to `...`, or both.
#'
#' @param data A data frame
#' @param ... Optional; bare column names to be used for groupings.
#' @param group Bare column name where groups are given--that is, the denominator value should be found in this column
#' @param denom String; denominator to filter from `group`
#' @param value Bare column name of values. Replaces previous `estimate` argument, but (for now) still defaults to a column named `estimate`
#' @param moe Bare column name of margins of error; if supplied, MOE of shares will be included in output
#' @param digits Number of digits to round to; defaults to 2.
#' @return A tibble/data frame with shares (and optionally MOE of shares) of subgroup values within a denominator group. Shares given for denominator group will be blank.
#' @examples
#' edu <- tibble::tribble(
#'     ~name,       ~edu, ~estimate,
#'     "Hamden", "ages25plus",     41017,
#'     "Hamden",  "bachelors",      8511,
#'     "Hamden",   "graduate",     10621,
#'     "New Haven", "ages25plus",     84441,
#'     "New Haven",  "bachelors",     14643,
#'     "New Haven",   "graduate",     17223
#' )
#' edu |>
#'     dplyr::group_by(name) |>
#'     calc_shares(group = edu, denom = "ages25plus", value = estimate)
#'
#' @keywords augmenting-functions
#' @export
calc_shares <- function(data,
                        ...,
                        group = group,
                        denom = "total_pop",
                        value = estimate,
                        moe = NULL,
                        digits = 2) {
    val_var <- rlang::enquo(value)
    grp_var <- rlang::enquo(group)

    # check for denom in grp_var
    if (!denom %in% data[[rlang::quo_name(grp_var)]]) {
        cli::cli_abort("The denominator {.val denom} doesn\'t seem to be in {.arg denom}.")
    }

    # should be grouped and/or have id
    if (dplyr::is_grouped_df(data)) {
        group_cols <- c(dplyr::groups(data), rlang::quos(...))
    } else if (length(rlang::quos(...)) == 0) {
        cli::cli_abort("Must supply a grouped data frame and/or give column names in {.arg ...}")
    } else {
        group_cols <- rlang::quos(...)
    }

    # group by all group_cols
    df_grp <- dplyr::group_by(data, !!!group_cols)

    join_names <- tidyselect::vars_select(names(data), !!!group_cols)
    join_cols <- rlang::quos(!!!group_cols)

    val_name <- rlang::quo_name(val_var)

    df2 <- dplyr::mutate(df_grp, {{group}} := as.character({{ group }}))

    df_left <- dplyr::filter(df2, {{ group }} == denom)
    df_left <- dplyr::select(df_left, -{{ group }})
    df_left <- dplyr::rename(df_left, ZZZ__val = {{ value }})
    df_right <- dplyr::filter(df2, {{ group }} != denom)

    # if including moe
    if (!rlang::quo_is_null(rlang::enquo(moe))) {
        moe_var <- rlang::enquo(moe)
        moe_name <- rlang::quo_name(moe_var)

        df_left <- dplyr::rename(df_left, ZZZ__moe = {{ moe }})

        calcs <- dplyr::inner_join(df_left, df_right, by = join_names)
        calcs <- dplyr::mutate(calcs, share = round({{ value }} / ZZZ__val, digits = digits))
        calcs <- dplyr::mutate(calcs, sharemoe = round(tidycensus::moe_prop({{ value }}, ZZZ__val, {{ moe }}, ZZZ__moe), digits = digits + 1))

        denom_rows <- dplyr::select(
            calcs,
            !!!join_cols,
            {{ value }} := ZZZ__val,
            {{ moe }} := ZZZ__moe
        )
    } else {
        calcs <- dplyr::inner_join(df_left, df_right, by = join_names)
        calcs <- dplyr::mutate(calcs, share = round({{ value }} / ZZZ__val, digits = digits))
        denom_rows <- dplyr::select(
            calcs,
            !!!join_cols,
            {{ value }} := ZZZ__val
        )
    }

    denom_rows <- dplyr::mutate(denom_rows, {{ group }} := denom)
    denom_rows <- unique(denom_rows)
    numer_rows <- dplyr::select(calcs, -dplyr::starts_with("ZZZ__"))
    out <- dplyr::bind_rows(denom_rows, numer_rows)
    out <- dplyr::mutate(out, {{ group }} := forcats::as_factor({{ group }}))
    out <- dplyr::mutate(out, {{ group }} := forcats::fct_relevel({{ group }}, denom))
    out <- dplyr::arrange(out, !!!join_cols, {{ group }})
    out <- dplyr::relocate(out, !!!join_cols, {{ group }})

    # ungroup if original df wasn't grouped
    if (!dplyr::is_grouped_df(data)) {
        out <- dplyr::ungroup(out)
    }
    out
}
