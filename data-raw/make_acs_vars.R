acs_vars <- tidycensus::load_variables(year = 2016, "acs5", cache = T) %>%
  dplyr::filter(stringr::str_detect(name, "_\\d{3}E$")) %>%
  dplyr::mutate(label = stringr::str_remove(label, "Estimate!!")) %>%
  dplyr::mutate(name = stringr::str_remove(name, "E$"))

usethis::use_data(acs_vars, overwrite = T)
