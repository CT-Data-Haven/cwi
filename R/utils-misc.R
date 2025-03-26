split_n <- function(x, len) {
    i <- seq_along(x) - 1
    split(x, floor(i / len))
}

cache_id <- function() {
    opt <- getOption("cwi.cache_id", default = NULL)
    if (is.null(opt)) {
        "cwi"
    } else {
        opt
    }
}

prep_cache <- function(id = cache_id(), cache_dir = NULL) {
    if (is.null(cache_dir)) {
        cache_dir <- rappdirs::user_cache_dir(id)
    } else {
        cache_dir <- file.path(cache_dir, id)
    }
    # cache_dir <- rappdirs::user_cache_dir(id)
    cache <- cachem::cache_disk(
        dir = cache_dir,
        max_age = 7 * 24 * 60 * 60,
        evict = "fifo"
    )
    cache
}

clear_cache <- function() {
    memoise::drop_cache(check_cb_avail)()
    memoise::drop_cache(check_qwi_avail)()
    invisible(FALSE)
}

cws_check_yr <- function(path, year, verbose) {
    if (length(path) > 1) {
        cli::cli_abort("Because of how it handles parsing years, `cws_check_yr` only takes 1 path at a time.")
    }
    if (is.null(year) & is.null(path)) {
        cli::cli_abort("Guessing the year is only available for functions that take a path argument. Please supply the year explicitly.")
    }
    # if not numeric, try:
    # * to coerce
    # * to guess before error
    if (!is.null(year)) {
        if (!is.numeric(year)) {
            year <- suppressWarnings(as.numeric(year))
        }
        if (is.na(year) | year < 1900 | year > 2100) {
            year <- NULL
        }
    }
    if (is.null(year)) {
        guessing <- TRUE
        # match year pattern, get last match
        # also need to handle test files
        if (grepl("test_xtab", path)) {
            patt <- "(\\d{4})"
        } else {
            patt <- "(?<=\\D)(\\d{4})(?=[\\b\\-_\\s])"
        }
        year <- stringr::str_extract_all(basename(path), patt)[[1]]
        year <- year[length(year)]
        year <- as.numeric(year)
        if (verbose) {
            cli::cli_inform(c("Guessing year from the path",
                "i" = "Based on the path {path}, assuming {.var year} = {year}."
            ))
        }
    } else {
        guessing <- FALSE
    }
    if (!is.numeric(year)) {
        cli::cli_abort("{.var year} should be a number for the year or end year of the survey.")
    }
    if (year < 2015) {
        cli::cli_warn("This function was designed for DCWS crosstabs starting with 2015. Other years might have unexpected results.")
    }
    year
}

deprecation_msg <- function(fn_name, version, new_pkg, env = rlang::caller_env(n = 2), id = NULL) {
    fn_call <- stringr::str_glue("{fn_name}()")
    fn_new <- stringr::str_glue("{new_pkg}::{fn_call}")
    lifecycle::deprecate_warn(
        when = version,
        what = fn_call,
        with = fn_new,
        id = id,
        # env = rlang::caller_env(n = 2)
        user_env = env
    )
    # lifecycle::deprecate_warn("1.12.0", "read_xtabs()", "dcws::read_xtabs()",
    #                             details = "This function has been moved to the dcws package. Please use `dcws::read_xtabs` moving forward.",
    #                             id = "dcws-read")
}
