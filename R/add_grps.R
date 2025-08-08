#' Collapse variable into groups and sum
#'
#' This function makes it easy to collapse multiple labels of some column into groups, then sum them. The advantage of using this over simply relabeling a factor column (such as with `forcats::fct_collapse`) is that categories here don't have to be mutually exclusive. For example, from a table of populations by age group, you could collapse and aggregate into total population, people 18+, and people 65+ all within a single function call.
#'
#' The quickest and most fool-proof way to create aggregate groups is to give their positions within a column's unique values. In this example column of ages:
#' ```
#' 1 ages 0-5
#' 2 ages 6-17
#' 3 ages 18-34
#' 4 ages 35-64
#' 5 ages 65-84
#' 6 ages 85+
#' ```
#' you would calculate total population from positions 1-6, ages 18+ from positions 3-6, and ages 65+ from positions 5-6. [show_uniq()] is a helper function for finding these positions.
#' @param data A data frame; will honor grouping
#' @param grp_list A named list of groups to collapse `group` into, either as characters that _exactly_ match the labels in the grouping column, or as numbers giving the position of each label within unique values of the grouping column. Position numbers are easier to type correctly.
#' @param group Bare column name giving groups in data; will be converted to factor
#' @param value Bare column name of values. Defaults to `estimate`
#' @param moe Bare column name of margins of error; if supplied, MOEs of sums will be included in output
#' @return A data frame/tibble with sums of `estimate`. Retains grouping columns
#' @examples
#' # make a list of the positions of the groups you want to collapse
#' # e.g. education$edu_level[2:16] has the education levels that we consider
#' # less than high school
#' education |>
#'     dplyr::group_by(name) |>
#'     add_grps(
#'         list(
#'             ages25plus = 1,
#'             less_than_high_school = 2:16,
#'             high_school_plus = 17:25,
#'             bachelors_plus = 22:25
#'         ),
#'         group = edu_level, value = estimate
#'     )
#' @keywords augmenting-functions
#' @export
#' @seealso [show_uniq()]
add_grps <- function(data,
                     grp_list,
                     group = group,
                     value = estimate,
                     moe = NULL) {
    # grp_list should be named list of either character or numeric vectors
    if (length(names(grp_list)) == 0) {
        cli::cli_abort("{.arg grp_list} should be a named list of vectors.")
    }
    grp_types <- purrr::map_chr(grp_list, class)
    if (!all(grp_types %in% c("integer", "numeric", "character"))) {
        cli::cli_abort("{.arg grp_list} should be a named list of character or numeric vectors.")
    }

    group_cols <- dplyr::groups(data)
    grp_names <- names(grp_list)
    grp_var <- rlang::quo_name(rlang::enquo(group))

    # convert list of numeric positions to list of character labels
    grp_list_chars <- make_grps(dplyr::pull(data, {{ group }}), grp_list)
    # previously mapped over groups to filter data, but try switching to joining data frames
    lbls_df <- tibble::enframe(grp_list_chars, name = "XX_GROUP_LABELS", value = grp_var)
    lbls_df <- tidyr::unnest(lbls_df, cols = {{ group }})
    lbls_df[["XX_GROUP_LABELS"]] <- forcats::as_factor(lbls_df[["XX_GROUP_LABELS"]])

    grouped_data <- dplyr::inner_join(data, lbls_df, by = grp_var, relationship = "many-to-many")
    grouped_data <- dplyr::group_by(grouped_data, !!!group_cols, XX_GROUP_LABELS)

    if (!rlang::quo_is_null(rlang::enquo(moe))) {
        out <- dplyr::summarise(grouped_data,
                                {{ value }} := sum({{ value }}),
                                {{ moe }} := round(tidycensus::moe_sum(moe = {{ moe }}, estimate = {{ value }})))
    } else {
        out <- dplyr::summarise(grouped_data, {{ value }} := sum({{ value }}))
    }
    out <- dplyr::ungroup(out)
    out <- dplyr::rename(out, {{ group }} := XX_GROUP_LABELS)
    out <- dplyr::arrange(out, !!!group_cols, {{ group }})
    # return grouped if it started that way
    out <- dplyr::group_by(out, !!!group_cols)
    out
}

