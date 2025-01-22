split_n <- function(x, len) {
    i <- seq_along(x) - 1
    split(x, floor(i / len))
}
