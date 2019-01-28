library(tidyverse)

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
    mutate_all(funs(!is.na(.)))

  .data %>%
    mutate(count_valid = rowSums(valids))
}

mark_questions <- function(.data, col = x1, pattern = "^[A-Z\\d]{1,20}$") {
  info_col <- enquo(col)
  marked <- .data %>%
    count_valid_cols() %>%
    mutate(is_question = !is.na(!!info_col) & !str_detect(!!info_col, pattern) & count_valid == 1,
           is_code = !is.na(!!info_col) & str_detect(!!info_col, pattern) & count_valid == 1) %>%
    mutate(q_number = cumsum(is_question)) %>%
    mutate(q = ifelse(is_question, !!info_col, NA_character_))  %>%
    fill(q, .direction = "down")

  codes <- suppressWarnings(question_codes(marked, col = info_col, pattern = pattern))

  # dropping q after the fact to handle joining with the 2015 tables
  marked %>%
    filter(!is_question, !is_code) %>%
    select(-q) %>%
    left_join(codes, by = c("q_number")) %>%
    select(code, question = q, everything(), -count_valid, -is_question, -is_code, -q_number)
}

question_codes <- function(.data, col, pattern) {
  # info_col <- enquo(col)
  # for 2015, already in 1 column which needs to be separated. Can detect this because there will be no true values in is_code
  if (!any(.data[["is_code"]])) {
    # no standalone codes --> separate codes and questions using pattern
    anti_pattern <- pattern %>%
      str_remove("\\$") %>%
      sprintf("(?<=%s)\\b", .)
    .data %>%
      mutate(q = str_remove_all(q, "\\.")) %>%
      separate(q, into = c("code", "q"), sep = anti_pattern, fill = "left") %>%
      mutate(q = str_trim(q)) %>%
      filter(!is.na(code)) %>%
      select(q_number, code, q) %>%
      distinct()
  } else {
    # standalone codes --> reshape into 2 columns
    .data %>%
      filter(is_question | is_code) %>%
      select(q_number, !!col, is_question, is_code) %>%
      gather(key, value, is_question, is_code) %>%
      filter(value) %>%
      spread(key = key, value = !!col) %>%
      filter(!is.na(is_code)) %>%
      select(q_number, code = is_code, q = is_question)
  }
}

######## functions to export

filter_until <- function(.data, col, pattern) {
  info_col <- enquo(col)
  .data %>%
    filter(cumsum(grepl(pattern, !!info_col)) == 0)
}

xtab2df <- function(.data, col = x1, code_pattern = "^[A-Z\\d]{1,20}$") {
  info_col <- enquo(col)

  marked <- .data %>%
    mark_questions(col = !!info_col, pattern = code_pattern)
  marked

  headings <- marked %>%
    mutate(code = as_factor(code)) %>%
    filter(is.na(!!info_col)) %>%
    janitor::remove_empty("cols") %>%
    group_by(code, question) %>%
    mutate(h = paste0("h", row_number())) %>%
    gather(key, value = heading, -code, -question, -h) %>%
    mutate(key = as_factor(key)) %>%
    spread(key = h, value = heading) %>%
    fill(matches("h\\d+"), .direction = "down") %>%
    mutate(h1 = coalesce(h1, h2)) %>%
    ungroup() %>%
    mutate_if(is.factor, as.character)

  marked %>%
    filter(!is.na(!!info_col)) %>%
    gather(key, value, -code, -question, -!!info_col) %>%
    left_join(headings, by = c("code", "question", "key")) %>%
    select(code, question, category = h1, group = h2, response = !!info_col, value) %>%
    mutate(value = as.numeric(value))
}

sub_nonanswers <- function(.data, response = response, value = value, nons = c("Don't know", "Refused"), output_tidy = T) {
  response_col <- enquo(response)
  value_col <- enquo(value)
  non_cols <- rlang::syms(nons)

  responses <- .data %>%
    pull(!!response_col) %>%
    unique() %>%
    setdiff(nons) %>%
    rlang::syms()
  wide <- .data %>%
    mutate_if(is.character, as_factor) %>%
    spread(key = !!response_col, value = !!value_col) %>%
    rowwise() %>%
    mutate(non_sum = sum(!!!non_cols)) %>%
    ungroup() %>%
    select(-one_of(nons)) %>%
    mutate_at(vars(!!!responses), funs(round(. / (1 - non_sum), digits = 3))) %>%
    select(-non_sum)

  if (output_tidy) {
    wide %>%
      gather(key = !!response_col, value = !!value_col, !!!responses)
  } else {
    wide
  }
}


read_xtabs <- function(path, col_names = F, name_prefix = "x", until = "Nature of the [Ss]ample", year = 2018) {
  data <- readxl::read_excel(path, col_names = col_names) %>%
    set_names(names(.) %>% str_replace("^\\.+", name_prefix)) %>%
    janitor::remove_empty(which = "rows")
  first_col <- rlang::sym(names(data)[1])
  if (year == 2015) {
    data <- data %>% slice(-1:-3)
  }
  data <- data %>%
    filter(!str_detect(!!first_col, "Weighted [Tt]otal") | is.na(!!first_col))
  if (!is.null(until)) {
    data %>%
      filter_until(!!first_col, until)
  } else {
    data
  }
}

##############################################################

ct18 <- read_xtabs("DataHaven2018 Connecticut Statewide Crosstabs Pub.xlsx")

ct18_long <- ct18 %>%
  xtab2df()

# default is a long format
ct18_long %>%
  filter(code == "Q6") %>%
  sub_nonanswers(nons = c("Don't know", "Refused"))

# output_tidy = F gives wide format
ct18_long %>%
  filter(code == "Q6") %>%
  sub_nonanswers(nons = c("Don't know", "Refused"), output_tidy = F)

# setting year = 2015 removes first 3 rows
ct15 <- read_xtabs("DataHaven2015 Connecticut Crosstabs Pub.xlsx", year = 2015)

ct15 %>%
  xtab2df()
