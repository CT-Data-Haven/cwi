regions <- readr::read_csv("./files/town_region_lookup.csv") %>%
  dplyr::filter(!is.na(region)) %>%
  split(.$region) %>%
  purrr::map(dplyr::pull, town)

usethis::use_data(regions, overwrite = T)
