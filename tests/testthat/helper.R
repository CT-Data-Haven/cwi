demo_xt <- function(f) {
  system.file("extdata", sprintf("test_xtab%s.xlsx", f), package = "cwi")
}

all_xt <- function(.fun, args = NULL) {
  c(2015, 2018, 2020) %>%
    rlang::set_names() %>%
    purrr::map(demo_xt) %>%
    purrr::imap(~R.utils::doCall(.fcn = .fun, path = .x, year = .y, args = args))
}
