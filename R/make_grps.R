
#' Collapse variable into subgroup positions, for use in `add_grps`.
#' @param x Character vector
#' @param grps Named list of variable values or positions within vector `x`
#' @return Named list of variable values from given positions
#' @keywords internal
make_grps <- function(x, grps) {
  x_uniq <- unique(x)

  purrr::map(grps, function(grp) {
    if (is.numeric(grp)) {
      x_uniq[grp]
    } else {
      if (!all(grp %in% x)) {
        # values that aren't actually in column
        errs <- setdiff(grp, x)
        cli::cli_abort(c("Invalid values in at least one group",
                         "i" = "{.val errs} don't occur in original data"))
      }
      grp
    }
  })
}
