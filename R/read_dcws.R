#' @title Read crosstab data and weights
#' @description
#' These two functions facilitate reading in Excel
#' spreadsheets of crosstabs generated from SPSS. Note that they're likely
#' only useful for working with the DataHaven Community Wellbeing Survey.
#' @param path Path to an excel file
#' @param name_prefix String used to create column names such as x1, x2, x3, ...,
#' Default: 'x'
#' @param marker String/regex pattern used to demarcate crosstabs from weight
#' table. If `NULL`, it will be assumed that the file contains only crosstab
#' data *or* weights, and no filtering will be done. If `marker` is never found,
#' it's assumed that weights are in headers above the data, such as for 2021,
#' in which case a different operation is done but the same weights table is
#' returned. Default: `"Nature of the [Ss]ample"`
#' @param year Numeric: year of the survey (or end year, in the case of pooled data).
#' This tells the functions how to read the files, since formatting has changed
#' across years of the survey. Because the ability to read a file depends so much
#' on the year for which it was produced, this argument no longer defaults to a
#' specific year. Instead, if `NULL` (the default), it will be guessed from the
#' path. Supplying it explicitly is better, but this serves as a fallback.
#' @param process Logical: if `FALSE` (the default), this will return the
#' crosstab data to be processed, most likely by passing along to `xtab2df`. If
#' `TRUE`, `xtab2df` will be called, and you'll receive a nice, clean data frame
#' ready for analysis. This is *only* recommended if you already know for sure
#' what the crosstab data looks like, so you don't accidentally lose some
#' questions or important description. As a sanity check, you'll see a message
#' listing the parameters used in the `xtab2df` call.
#' @param verbose Logical: if `process` is true, should parameters being passed to
#' `xtab2df` be printed? Defaults to `TRUE` to encourage you to double check that
#' you're passing arguments intentionally.
#' @param ... Additional arguments passed on to `xtab2df` if `process = TRUE`.
#' @return A data frame. For `read_xtabs`, there will be one column per
#' demographic/geographic group included, plus one for the questions & answers.
#' For `read_weights`, only 2 columns, one for demographic groups and one for
#' their associated weights.
#' @examples
#' if (interactive()) {
#'     xt <- system.file("extdata/test_xtab2018.xlsx", package = "cwi")
#'     read_weights(xt, year = 2018)
#'
#'     # returns a not-very-pretty data frame of the crosstabs to be processed
#'     read_xtabs(xt, year = 2018)
#'     # returns a pretty data frame ready for analysis
#'     read_xtabs(xt, year = 2018, process = TRUE)
#' }
#' @export
#' @rdname read_xtabs
#' @seealso [cwi::xtab2df()]
read_xtabs <- function(path,
                       name_prefix = "x",
                       marker = "Nature of the [Ss]ample",
                       year = NULL,
                       process = FALSE,
                       verbose = TRUE,
                       ...) {
    # return columns code, question, category, group, response, value
    year <- cws_check_yr(year, path)

    data <- read_xtabs_(path, name_prefix, year)

    first_col <- rlang::sym(names(data)[1])
    # can skip with 2024 formatting
    if (year < 2024) {
        if (year == 2015) {
            data <- camiller::filter_after(data, grepl("Samp[le]+ Size", {{ first_col }}))
        }
        data <- dplyr::filter(data, !stringr::str_detect({{ first_col }}, total_patt()) | is.na({{ first_col }}))
        if (!is.null(marker)) {
            data <- camiller::filter_until(data, grepl(marker, {{ first_col }}))
        }
    }
    if (process) {
        if (verbose) {
            xt_params(list(col = first_col, year = year, ...))
        }
        xtab2df(data, year = year, col = {{ first_col }}, ...)
    } else {
        data
    }
}


#' @export
#' @rdname read_xtabs
read_weights <- function(path, year, marker = "Nature of the [Ss]ample") {
    # return columns group & weight
    year <- cws_check_yr(year, path)

    if (year < 2024) {
        wts <- read_wts_spss_(path, marker, year)
    } else {
        wts <- read_wts_r_(path)
    }

    wts
}

#################### HELPERS ##########################################
total_patt <- function() {
    "(Weighted [Tt]otal|^Total\\:$)"
}

prefix_names <- function(x, prefix) {
    rlang::set_names(x, function(n) paste0(prefix, 1:length(x)))
}


# read xtabs: don't use col names, prefix names
# spss: filter til marker (opt)
# r:
# both: drop empty rows
# spss versions need clean names, filtering til marker
read_xtabs_ <- function(path, name_prefix, year) {
    if (year < 2024) {
        sheet <- 1
        drop_title <- FALSE
    } else {
        sheet <- 2
        drop_title <- TRUE
    }
    out <- readxl::read_excel(path, sheet = sheet, col_names = FALSE, .name_repair = make.names)
    out <- prefix_names(out, name_prefix)
    out <- janitor::remove_empty(out, which = "rows")
    if (drop_title) {
        out <- dplyr::slice(out, -1)
    }
    out
}


# legacy crosstabs---spss exports
read_wts_spss_ <- function(path, marker, year) {
    data <- read_xtabs_(path, name_prefix = "x", year = year)

    # is marker in col1? yes --> wt_tbl; no --> wt_hdr
    has_wt_tbl <- !is.null(marker) & any(grepl(marker, data[[1]]))

    if (has_wt_tbl) {
        data <- camiller::filter_after(data, grepl(marker, data[[1]]))
        wts <- read_wt_tbl(data)
    } else {
        data <- camiller::filter_until(data, grepl(total_patt(), dplyr::lag(data[[1]])))
        data <- dplyr::select(data, -1)
        data <- janitor::remove_empty(data, which = "rows")
        wts <- read_wt_hdr(data, scale = TRUE)
    }
    wts
}

# new crosstabs---with r
read_wts_r_ <- function(path) {
    wts <- readxl::read_excel(path, sheet = 3, skip = 1)
    wts <- dplyr::select(wts, group = Group, weight = `Weighted share`)
    wts
}

read_wt_tbl <- function(data) {
    out <- janitor::remove_empty(data, which = "cols")
    out <- dplyr::select(out, group = 1, weight = 2)
    out <- dplyr::filter(out, !is.na(weight))
    out <- dplyr::mutate(out, weight = round(as.numeric(weight), digits = 3))
    out
}

read_wt_hdr <- function(data, scale) {
    out <- t(data)
    out <- as.data.frame(out)
    names(out) <- c("category", "group", "weight")
    out <- tidyr::fill(out, category, .direction = "down")
    out <- dplyr::filter(out, !is.na(category))
    out$weight <- as.numeric(out$weight)
    out <- dplyr::group_by(out, category)

    if (scale) out <- dplyr::mutate(out, weight = round(weight / sum(weight), digits = 3))

    out <- dplyr::ungroup(out)
    out <- dplyr::select(out, -category)
    out
}

xt_params <- function(args) {
    defaults <- formals(xtab2df)
    # don't need to include .data
    from_def <- defaults[!names(defaults) %in% names(args)][-1]
    params <- c(from_def, args)
    params <- params[names(defaults)[-1]]
    if (is.null(params[["code_pattern"]])) {
        params[["code_pattern"]] <- "`NULL` (filling in default pattern)"
    } else {
        params[["code_pattern"]] <- gsub("\\{", "{{", params[["code_pattern"]])
        params[["code_pattern"]] <- gsub("\\}", "}}", params[["code_pattern"]])
    }
    param_str <- paste(names(params), params, sep = " = ")
    # param_str <- stats::setNames(param_str, rep_len("*", length(param_str)))
    cli::cli_alert_info("xtab2df is being called on the data with the following parameters:")
    purrr::walk(param_str, cli::cli_alert)
}
