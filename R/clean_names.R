# simplified port of janitor::clean_names so I can cull dependencies
clean_names <- function(x, allow_dupes = FALSE) {
    if (!inherits(x, "data.frame")) {
        cli::cli_abort(c("{.fun clean_names} is intended for use on data frames (or things that inherit properties of data frames)",
            "i" = "Try the function's underlying {.fun make_clean_names}."
        ))
    }
    new_names <- make_clean_names(names(x), allow_dupes)
    setNames(x, new_names)
}

count_dupes <- function(x) {
    dupes <- purrr::map_dbl(seq_along(x), function(i) {
        sum(x[i] == x[1:i])
    })
    x[dupes > 1] <- paste(x[dupes > 1], dupes[dupes > 1], sep = "_")
    x
}

make_clean_names <- function(x, allow_dupes = FALSE) {
    # before replacing punct, handle ends
    x <- stringr::str_remove_all(x, "^[[:punct:]\\s\\-\\.]+")
    x <- stringr::str_remove_all(x, "[[:punct:]\\s\\-\\.]+$")
    # before lowercase, handle mixed case
    # split at mixed case: lower followed by upper
    x <- stringr::str_replace_all(x, "(?<=[a-z])(\\B)(?=[A-Z])", " ")
    # hyphens -> space, squish
    x <- stringr::str_replace_all(x, "[[:punct:]\\-\\.]+", " ")
    x <- stringr::str_replace_all(x, "\\s+", "_")
    x <- tolower(x)
    # escape leading digits
    x <- stringr::str_replace(x, "^(\\d)", "x\\1")

    # count along dupes
    if (!allow_dupes) {
        if (any(duplicated(x))) {
            x <- count_dupes(x)
        }
    }
    x
}