acs_vars <- tidycensus::load_variables(year = 2016, "acs5", cache = T) %>%
  dplyr::filter(stringr::str_detect(name, "_\\d{3}E$")) %>%
  dplyr::mutate(label = stringr::str_remove(label, "Estimate!!")) %>%
  dplyr::mutate(name = stringr::str_remove(name, "E$"))

usethis::use_data(acs_vars, overwrite = T)

decennial_vars <- tidycensus::load_variables(year = 2010, "sf1", cache = T) %>%
  dplyr::filter(stringr::str_detect(name, "^(H|P|HCT|PCO|PCT)\\d+"))

decennial_nums <- decennial_vars %>%
  dplyr::filter(!stringr::str_detect(name, "^H0001")) %>%
  dplyr::pull(name) %>%
  stringr::str_extract("^(H|P|HCT|PCT|PCO)\\d{3}[A-Z]?") %>%
  unique()

usethis::use_data(decennial_vars, overwrite = T)

