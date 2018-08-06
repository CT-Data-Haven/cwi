acs_vars16 <- clean_acs_vars(year = 2016, survey = "acs5")

usethis::use_data(acs_vars16, overwrite = T)

# there's an error in P012, sex by age, where female, all ages is labeled as female, 85 and up

decennial_vars10 <- clean_decennial_vars(year = 2010, sumfile = "sf1") %>%
  mutate(label = ifelse(str_detect(name, "^P012\\D?0026"), "Female:", label))

decennial_nums <- decennial_vars10 %>%
  dplyr::filter(!stringr::str_detect(name, "^H0001")) %>%
  dplyr::pull(name) %>%
  stringr::str_extract("^(H|P|HCT|PCT|PCO)\\d{3}[A-Z]?") %>%
  unique()

usethis::use_data(decennial_vars10, overwrite = T)
