acs_vars16 <- clean_acs_vars(year = 2016, survey = "acs5")

usethis::use_data(acs_vars16, overwrite = T)

# P012 numbers have been changed to more standard in the API as of 8/2018; label for female, all ages has been fixed

decennial_vars10 <- clean_decennial_vars(year = 2010, sumfile = "sf1")

decennial_nums <- decennial_vars10 %>%
  dplyr::filter(!stringr::str_detect(name, "^H0001")) %>%
  dplyr::pull(name) %>%
  stringr::str_extract("^(H|P|HCT|PCT|PCO)\\d{3}[A-Z]?") %>%
  unique()

usethis::use_data(decennial_vars10, overwrite = T)
