#' @title Quickly cut a vector with the Jenks/Fisher algorithms
#' @description Given a numeric vector, this returns a factor of those values cut
#' into `n` number of breaks using the Jenks/Fisher algorithms. The algorithm(s) sets breaks in a way that highlights very high or very low values well. It's good to use for choropleths that need to convey imbalances or inequities.
#' @param x A numeric vector to cut
#' @param n Number of bins, Default: 5
#' @param true_jenks Logical: should a "true" Jenks algorithm be used? If false, uses the faster Fisher-Jenks algorithm. See `classInt::classIntervals` docs for discussion. Default: FALSE
#' @param labels A string vector to be used as bin labels, Default: NULL
#' @param ... Additional arguments passed on to [`base::cut`]
#' @return A factor of the same length as x
#' @examples
#'  set.seed(123)
#'  values <- rexp(30, 0.8)
#'  jenks(values, n = 4)
#' @seealso [`classInt::classIntervals`]
#' @export
jenks <- function(x, n = 5, true_jenks = FALSE, labels = NULL, ...) {
  if (!is.numeric(x)) cli::cli_abort("{.var x} must be numeric.")
  if (n < 2) cli::cli_abort("{.var n} must be 2 or more.")
  if (n >= length(x)) cli::cli_abort("{.var n} must be less than the number of values to cut.")
  if (n >= length(unique(x))) cli::cli_warn(c("{.var n} should be less than the number of unique values to cut.", "Breaks might not be meaningful."))
  if (true_jenks) {
    brks <- unique(suppressWarnings(classInt::classIntervals(x, n = n, style = "jenks")$brk))
  } else {
    brks <- unique(suppressWarnings(classInt::classIntervals(x, n = n, style = "fisher")$brk))
  }
  cut(x, include.lowest = TRUE, breaks = brks, labels = labels, ...)
}
