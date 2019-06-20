# logic:
# * Questions are divided from one another by a row of all NA
# * For 2018, question labels are a string value in x1 followed by a row of all NA, but so is Q1 label. And some rows have a code other than Q1, such as MOVEYEAR, so these are detected with regex as being only 1-20 capital letters and/or numbers
# * Headings should be paired into 2 columns, i.e. category = Age, group = 35-49
# * Files are read until reaching some stop-pattern; by default, that's "Nature of the Sample" or "Nature of the sample"
# * For 2015, use slice to remove first 3 rows that give the region name, moe and weights. Doing this dynamically would be better.
# * For 2018, codes are on their own row; for 2015, they're placed together with the question. I'd prefer a more dynamic way of doing this also but for now ¯\_(ツ)_/¯
# * I'm going to move filter_until into the camiller package because it's pretty handy outside of just this

########### UTILITY FUNCS ####################################
########### don't export
count_valid_cols <- function(.data) {
  valids <- .data %>%
    dplyr::mutate_all(dplyr::funs(!is.na(.)))

  .data %>%
    dplyr::mutate(count_valid = rowSums(valids))
}

mark_questions <- function(.data, col = x1, pattern = "^[A-Z\\d_]{1,20}$") {
  info_col <- rlang::enquo(col)
  marked <- .data %>%
    count_valid_cols() %>%
    dplyr::mutate(is_question = !is.na(!!info_col) & !stringr::str_detect(!!info_col, pattern) & count_valid == 1,
           is_code = !is.na(!!info_col) & stringr::str_detect(!!info_col, pattern) & count_valid == 1) %>%
    dplyr::mutate(q_number = cumsum(is_question)) %>%
    dplyr::mutate(q = ifelse(is_question, !!info_col, NA_character_))  %>%
    tidyr::fill(q, .direction = "down")

  codes <- suppressWarnings(question_codes(marked, col = info_col, pattern = pattern))

  # dropping q after the fact to handle joining with the 2015 tables
  marked %>%
    dplyr::filter(!is_question, !is_code) %>%
    dplyr::select(-q) %>%
    dplyr::left_join(codes, by = c("q_number")) %>%
    dplyr::select(code, question = q, dplyr::everything(), -count_valid, -is_question, -is_code, -q_number)
}

question_codes <- function(.data, col, pattern) {
  # info_col <- enquo(col)
  # for 2015, already in 1 column which needs to be separated. Can detect this because there will be no true values in is_code
  if (!any(.data[["is_code"]])) {
    # no standalone codes --> separate codes and questions using pattern
    anti_pattern <- pattern %>%
      stringr::str_remove("\\$") %>%
      sprintf("(?<=%s)\\b", .)
    .data %>%
      dplyr::mutate(q = str_remove_all(q, "\\.")) %>%
      tidyr::separate(q, into = c("code", "q"), sep = anti_pattern, fill = "left") %>%
      dplyr::mutate(q = str_trim(q)) %>%
      dplyr::filter(!is.na(code)) %>%
      dplyr::select(q_number, code, q) %>%
      dplyr::distinct()
  } else {
    # standalone codes --> reshape into 2 columns
    .data %>%
      dplyr::filter(is_question | is_code) %>%
      dplyr::select(q_number, !!col, is_question, is_code) %>%
      tidyr::gather(key, value, is_question, is_code) %>%
      dplyr::filter(value) %>%
      tidyr::spread(key = key, value = !!col) %>%
      dplyr::filter(!is.na(is_code)) %>%
      dplyr::select(q_number, code = is_code, q = is_question)
  }
}

######## functions to export

filter_until <- function(.data, col, pattern) {
  info_col <- rlang::enquo(col)
  .data %>%
    dplyr::filter(cumsum(grepl(pattern, !!info_col)) == 0)
}

filter_after <- function(.data, col, pattern) {
  info_col <- rlang::enquo(col)
  .data %>%
    dplyr::filter(cumsum(grepl(pattern, !!info_col)) > 0)
}

xtab2df <- function(.data, col = x1, code_pattern = "^[A-Z\\d_]{1,20}$") {
  info_col <- rlang::enquo(col)
  hier <- c("category", "group", "subgroup")

  marked <- .data %>%
    mark_questions(col = !!info_col, pattern = code_pattern)

  headings <- marked %>%
    dplyr::mutate(code = forcats::as_factor(code)) %>%
    dplyr::filter(is.na(!!info_col)) %>%
    janitor::remove_empty("cols") %>%
    dplyr::slice(1:2) %>%
    dplyr::group_by(code, question) %>%
    dplyr::mutate(h = paste0("h", dplyr::row_number())) %>%
    dplyr::ungroup() %>%
    # new
    dplyr::select(-code, -question) %>%
    # gather(key, value = heading, -code, -question, -h) %>%
    tidyr::gather(key, value = heading, -h) %>%
    dplyr::mutate(key = forcats::as_factor(key)) %>%
    tidyr::spread(key = h, value = heading) %>%
    dplyr::mutate_if(is.factor, as.character) %>%
    tidyr::fill(dplyr::matches("h\\d+"), .direction = "down") %>%
    # mutate(h1 = coalesce(h1, h2)) %>%
    dplyr::mutate(h1 = dplyr::coalesce(!!!dplyr::select(., dplyr::matches("^h\\d+"))))

  marked %>%
    dplyr::filter(!is.na(!!info_col)) %>%
    tidyr::gather(key, value, -code, -question, -!!info_col) %>%
    dplyr::left_join(headings, by = c("key")) %>%
    dplyr::select(code, question, dplyr::matches("^h\\d+"), response = !!info_col, value) %>%
    dplyr::rename_at(dplyr::vars(dplyr::matches("^h\\d+")), ~hier[seq_along(.)]) %>%
    dplyr::mutate(value = as.numeric(value)) %>%
    dplyr::filter(!is.na(value))
}

sub_nonanswers <- function(.data, response = response, value = value, nons = c("Don't know", "Refused"), output_tidy = T) {
  response_col <- rlang::enquo(response)
  value_col <- rlang::enquo(value)
  non_cols <- rlang::syms(nons)

  responses <- .data %>%
    dplyr::pull(!!response_col) %>%
    unique() %>%
    setdiff(nons) %>%
    rlang::syms()
  wide <- .data %>%
    dplyr::ungroup() %>%
    dplyr::mutate_if(is.character, forcats::as_factor) %>%
    tidyr::spread(key = !!response_col, value = !!value_col) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(non_sum = sum(!!!non_cols)) %>%
    dplyr::ungroup() %>%
    dplyr::select(-dplyr::one_of(nons)) %>%
    dplyr::mutate_at(dplyr::vars(!!!responses), .funs = list(. / (1 - non_sum))) %>%
    dplyr::select(-non_sum)

  if (output_tidy) {
    wide %>%
      tidyr::gather(key = !!response_col, value = !!value_col, !!!responses) %>%
      dplyr::mutate_at(dplyr::vars(!!response_col), forcats::as_factor)
  } else {
    wide
  }
}


read_xtabs <- function(path, col_names = F, name_prefix = "x", until = "Nature of the [Ss]ample", year = 2018) {
  data <- readxl::read_excel(path, col_names = col_names, .name_repair = "minimal") %>%
    rlang::set_names(paste0(name_prefix, 1:ncol(.))) %>%
    janitor::remove_empty(which = "rows")
  first_col <- rlang::sym(names(data)[1])
  if (year == 2015) {
    data <- data %>% dplyr::slice(-1:-3)
  }
  data <- data %>%
    dplyr::filter(!stringr::str_detect(!!first_col, "Weighted [Tt]otal") | is.na(!!first_col))
  if (!is.null(until)) {
    data %>%
      filter_until(!!first_col, until)
  } else {
    data
  }
}

read_weights <- function(path, marker = "Nature of the [Ss]ample") {
  data <- readxl::read_excel(path, col_names = F, .name_repair = "minimal") %>%
    rlang::set_names(paste0("x", 1:ncol(.)))
  first_col <- rlang::sym(names(data)[1])

  data %>%
    filter_after(!!first_col, marker) %>%
    janitor::remove_empty(which = c("rows", "cols")) %>%
    rlang::set_names(c("group", "weight")) %>%
    dplyr::filter(!is.na(weight)) %>%
    dplyr::mutate(weight = as.numeric(weight) %>% round(digits = 3))
}
