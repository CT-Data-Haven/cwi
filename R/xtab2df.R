#' @title Extract survey data and descriptions from crosstabs into a tidy data frame
#' @description
#' `r lifecycle::badge("deprecated")` **Deprecation notice:** Crosstab-related
#' functions have been moved from cwi to the dcws package. The versions here will be removed soon.
#' Like `read_xtab` & `read_weights`, this is a bespoke function
#' to make it easier to extract data from the DataHaven Community Wellbeing
#' Survey. Applications to other crosstabs are probably limited unless their
#' formatting is largely the same. After reading a crosstab excel file, `xtab2df`
#' extracts the question codes (e.g. Q4A), question text, categories, and
#' demographic groups, and joins those descriptions with survey responses and
#' values, making it ready for analysis. Under the hood there are 2 versions of this
#' function: one for crosstabs generated from SPSS (pre-2024 DCWS), and one for
#' crosstabs generated at DataHaven starting in 2024. Those in-house crosstabs
#' don't have categories included in headings in excel, but this function will
#' add them.
#' @param data A data frame as returned from `read_xtab`.
#' @param col The bare column name of where to find question codes and text.
#' Default: x1, based on names assigned by `read_xtab`
#' @param code_pattern String: regex pattern denoting how to find cells that
#' contain only a question code, such as "Q10", "Q4B", or "ASTHMA", or to
#' split codes and question text within the same cell. This is
#' pretty finicky, so you probably don't want to change it.
#' If `NULL` (the default), the function will fill in `"^[A-Z\\d_]{2,20}$"` for
#' years before 2024, or `"^[A-Z\\d_]+(?=\\. )"` for 2024 onward.
#' @param year Numeric: year of the survey (or end year, in the case of pooled data).
#' This tells the functions how to read the files, since formatting has changed
#' across years of the survey. Because the ability to read a file depends so much
#' on the year for which it was produced, this argument no longer has a default;
#' instead it must be supplied explicitly.
#' @return A data frame with the following columns:
#' * code (if questions have codes in crosstabs)
#' * q_number (if questions don't have codes in crosstabs, assigned in order they occur)
#' * question
#' * category (e.g. age, gender)
#' * group (e.g. 18–34, male)
#' * response
#' * value
#' @examples
#' \dontrun{
#' # this function is being deprecated
#' # replace with the equivalent in the dcws package
#' xt <- system.file("extdata/test_xtab2018.xlsx", package = "dcws")
#' xtab <- dcws::read_xtabs(xt, year = 2018)
#' dcws::xtab2df(xtab, year = 2018)
#' }
#' @export
#' @seealso [dcws::read_xtabs()]
#' @family dcws-migration
#' @keywords internal
xtab2df <- function(data, year, col = x1, code_pattern = NULL) {
    deprecation_msg("xtab2df", "1.12.0", "dcws", id = "dcws-xtab2df")
    year <- cws_check_yr(path = NULL, year, TRUE)

    if (is.null(code_pattern)) {
        if (year < 2024) {
            code_pattern <- "^[A-Z\\d_]{2,20}$"
        } else {
            code_pattern <- "^[A-Z\\d_]+(?=\\. )"
        }
    }
    if (year < 2024) {
        out <- xtab2df_spss_(data, {{ col }}, code_pattern)
    } else {
        out <- xtab2df_r_(data, {{ col }}, code_pattern)
    }
    # fix misspellings in categories
    if ("category" %in% names(out)) {
        out[["category"]] <- stringr::str_remove(out[["category"]], "\\*$")
        out[["category"]] <- stringr::str_replace(out[["category"]], "Etnicity", "Ethnicity")
    }
    out
}

xtab2df_spss_ <- function(data, col, code_pattern) {
    # generally only includes first 2 hierarchy levels
    hier <- c("category", "group", "subgroup")

    marked <- mark_questions_spss_(data, col = {{ col }}, pattern = code_pattern)
    headings <- make_headings(marked, {{ col }})

    # get just data rows, attach headings (gender, age, etc)
    out <- dplyr::filter(marked, !is.na({{ col }}))
    out <- tidyr::pivot_longer(out, cols = -c(code, q_number, question, {{ col }}), names_to = "column")
    out <- dplyr::left_join(out, headings, by = "column")
    out <- dplyr::select(out, code, q_number, question, dplyr::matches("^h\\d+"), response = {{ col }}, value)
    out <- dplyr::rename_with(out, ~ hier[seq_along(.)], dplyr::matches("^h\\d+"))
    out <- dplyr::mutate(out, value = readr::parse_number(value))
    out <- dplyr::filter(out, !is.na(value))

    if (any(nchar(out$code) > 0)) {
        dplyr::select(out, -q_number)
    } else {
        dplyr::select(out, -code)
    }
}

xtab2df_r_ <- function(data, col, code_pattern) {
    # don't have categories---add separately
    marked <- mark_questions_r_(data, {{ col }}, code_pattern)
    marked <- dplyr::mutate(marked, code = forcats::as_factor(code))
    # in case questions have different groups, split by question and pivot separately
    mark_split <- split(marked, marked[["code"]])
    mark_split <- lapply(mark_split, reshape_single_xt_)
    out <- dplyr::bind_rows(mark_split)
    out[["value"]] <- readr::parse_number(out[["value"]])

    # r-format excel files don't have categories
    out <- dplyr::left_join(out, cws_cats24, by = "group")
    out <- dplyr::mutate(out, category = dplyr::if_else(grepl(" total$", group) & is.na(category), "Total", category))

    out <- dplyr::select(out, code, question, category, group, response = Response, value)
    out
}

#################### HELPERS ##########################################
rleid <- function(x, default = TRUE) {
    cumsum(x != dplyr::lag(x, default = default))
}

short_patt <- function(pattern) paste0(stringr::str_remove(pattern, "\\$"), "\\b")

count_valid_cols <- function(data) {
    # count number of non-NAs per row
    dplyr::mutate(data, count_valid = rowSums(!is.na(data)))
}

reshape_single_xt_ <- function(data) {
    # top row minus first 2 columns
    hdr <- as.data.frame(data)[1, -1:-2]
    names(data)[-1:-2] <- hdr
    out <- dplyr::filter(data, !stringr::str_detect(Response, "Response") & !stringr::str_detect(Response, "^Weight"))
    out <- tidyr::pivot_longer(out, cols = c(-code, -question, -Response), names_to = "group", values_to = "value")
    out
}

mark_questions_spss_ <- function(data, col, pattern) {
    # mark which rows only contain question text
    # if x1 is a question & lead(x1) is also a question, extract code & collapse--deals with lead-in lines that have code attached
    # this is so ugly
    marked <- count_valid_cols(data)
    marked <- dplyr::mutate(marked, is_question = !is.na({{ col }}) & !stringr::str_detect({{ col }}, pattern) & count_valid == 1)
    marked <- dplyr::mutate(marked, is_code = !is.na({{ col }}) & stringr::str_detect({{ col }}, pattern) & count_valid == 1)
    marked <- dplyr::mutate(marked, is_leadin = is_question & dplyr::lead(is_question, default = FALSE))
    marked <- dplyr::mutate(marked, q = dplyr::case_when(
        is_leadin ~ stringr::str_extract({{ col }}, short_patt(pattern)),
        is_question ~ {{ col }},
        TRUE ~ NA_character_
    ))
    marked <- dplyr::mutate(marked, rl = rleid(is_question))

    marked <- dplyr::group_by(marked, rl)
    marked <- dplyr::mutate(marked, q = dplyr::if_else(is_question, paste(stats::na.omit(q), collapse = ". "), q))
    marked <- dplyr::filter(marked, !is_leadin)
    marked <- dplyr::ungroup(marked)
    marked <- tidyr::fill(marked, q, .direction = "down")
    marked <- dplyr::mutate(marked, q_number = cumsum(is_question))

    codes <- question_codes(marked, col = {{ col }}, pattern = pattern)
    marked <- dplyr::filter(marked, !is_question & !is_code)
    marked <- dplyr::select(marked, -q)
    marked <- dplyr::left_join(marked, codes, by = "q_number")
    marked <- dplyr::select(marked, code, q_number, question = q, tidyselect::everything(), -count_valid, -is_question, -is_code, -is_leadin, -rl)
    marked
}

mark_questions_r_ <- function(data, col, pattern) {
    marked <- count_valid_cols(data)
    # fill questions downward, then drop question-only rows
    marked <- tidyr::fill(marked, {{ col }}, .direction = "down")
    marked <- dplyr::filter(marked, !(stringr::str_detect({{ col }}, pattern) & count_valid == 1))
    # separate by period & space
    marked <- tidyr::separate_wider_delim(marked, {{ col }}, delim = ". ", names = c("code", "question"), too_many = "merge")
    marked <- dplyr::select(marked, -count_valid)
    marked
}


question_codes <- function(.data, col, pattern) {
    # split out question numbers, e.g. Q4A
    # major difference is 2015 has qcode, question text in same cell. 2018 has qcode several rows below question text
    # 2020 follows same pattern as 2018
    # if no true values in is_code, both qcode & qtext are in same cell
    if (!any(.data[["is_code"]])) {
        # no separate codes --> split codes & questions by pattern
        split_patt <- short_patt(pattern)
        codes <- dplyr::mutate(.data, q = stringr::str_remove_all(q, "\\."))
        codes <- tidyr::extract(codes, q, into = c("code", "q"), regex = sprintf("(%s)?(.+$)", split_patt))
        codes <- dplyr::mutate(codes, dplyr::across(c(code, q), stringr::str_squish))
        codes <- dplyr::filter(codes, !is.na(code))
        codes <- dplyr::select(codes, q_number, code, q)
        codes <- dplyr::distinct(codes)
    } else {
        # standalone codes --> reshape into 2 columns of code & question
        codes <- dplyr::filter(.data, is_question | is_code)
        codes <- tidyr::pivot_longer(codes, cols = c(is_question, is_code))
        codes <- dplyr::filter(codes, value)
        codes <- tidyr::pivot_wider(codes, id_cols = q_number, values_from = {{ col }})
        codes <- dplyr::filter(codes, !is.na(is_code))
        codes <- dplyr::select(codes, q_number, code = is_code, q = is_question)
    }
    codes
}

make_headings <- function(.data, col) {
    # takes data after mark_questions, makes tiered headings e.g. h1 = age, h2 = 18-34
    hdrs <- dplyr::filter(.data, is.na({{ col }}))
    hdrs <- janitor::remove_empty(hdrs, which = "cols")
    hdrs <- utils::head(hdrs, 2)
    hdrs <- dplyr::mutate(hdrs, h = paste0("h", dplyr::row_number()))
    hdrs <- dplyr::select(hdrs, -code, -question, -q_number)
    hdrs <- tidyr::pivot_longer(hdrs, cols = -h, names_to = "column")
    hdrs <- tidyr::pivot_wider(hdrs, names_from = h)
    hdrs <- tidyr::fill(hdrs, dplyr::matches("^h\\d+"), .direction = "down")
    hdrs <- dplyr::mutate(hdrs, h1 = dplyr::coalesce(!!!dplyr::select(hdrs, dplyr::matches("^h\\d+"))))
}
