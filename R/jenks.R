#' @title jenks
#' @description Quickly cut a vector with the Jenks/Fisher algorithms
#' @param x A numeric vector to cut
#' @param n Number of bins, Default: 5
#' @param true_jenks Logical: should a "true" Jenks algorithm be used? If false, uses the faster Fisher-Jenks algorithm. See `classInt::classIntervals` docs for discussion. Default: FALSE
#' @param labels A string vector to be used as bin labels, Default: NULL
#' @param ... Additional arguments passed on to `cut`
#' @details The Jenks/Fisher algorithms cut a set of numbers into bins in a way that highlights very high or very low values well. It's good to use for choropleths that need to convey imbalances or inequities.
#' @return A factor of the same length as x
#' @examples
#'  set.seed(123)
#'  values <- rexp(30, 0.8)
#'  jenks(values, n = 4)
#' @export
#' @seealso classInt::classIntervals
#'
#' @import assertthat
#' @import classInt
jenks <- function(x, n = 5, true_jenks = FALSE, labels = NULL, ...) {
  assertthat::assert_that(is.numeric(x), msg = "x must be numeric")
  assertthat::assert_that(n > 1, msg = "n must be 2 or more")
  assertthat::assert_that(n < length(x), msg = "n must be less than the number of values to cut")
  assertthat::validate_that(n < length(unique(x)), msg = "n should be less than the number of unique values to cut\nBreaks might not be meaningful")
  if (true_jenks) {
    brks <- unique(classInt::classIntervals(x, n = n, style = "jenks")$brk)
  } else {
    brks <- unique(classInt::classIntervals(x, n = n, style = "fisher")$brk)
  }
  cut(x, include.lowest = TRUE, breaks = brks, labels = labels, ...)
}
