#' Print unique values from a data frame column, then keep it moving
#'
#' `show_uniq` gets the unique values of a column and their position within that vector, prints them neatly to the console, then returns the original data frame unchanged. It's just a convenience for showing the values in a column without breaking your workflow or train of thought, and is useful for identifying groups for `add_grps`.
#'
#' @param data A data frame
#' @param col Bare column name of interest
#' @return Original unchanged `data`
#' @examples
#' # show_uniq makes it easy to see that the values of `edu_level` that correspond
#' # to less than high school are in positions 2-16, and so on
#' education |>
#'     dplyr::group_by(name) |>
#'     show_uniq(edu_level) |>
#'     add_grps(
#'         list(
#'             ages25plus = 1,
#'             less_than_high_school = 2:16,
#'             high_school_plus = 17:25,
#'             bachelors_plus = 22:25
#'         ),
#'         group = edu_level, value = estimate
#'     )
#' @keywords utils
#' @export
show_uniq <- function(data, col) {
    values <- unique(dplyr::pull(data, {{ col }}))
    lbls <- purrr::imap_chr(values, function(lbl, id) {
        sprintf("% 3d: %s", id, lbl)
    })
    cat("\n")
    cat(prettycols(lbls), fill = TRUE)
    cat("\n")
    data
}

prettycols <- function(x) {
    w <- floor(options("width")$width * 0.98)
    l <- max(nchar(x))
    cols <- max(floor(w / l), 1)
    padded <- stringr::str_pad(x, width = l, side = "right")

    if (rlang::is_installed("crayon")) {
        pink <- crayon::make_style("orchid")
        padded <- pink(padded)
    }
    spl <- rep(1:ceiling(length(x) / cols), each = cols)
    out <- suppressWarnings(split(padded, spl))
    purrr::map_chr(out, paste, collapse = " ")
}
