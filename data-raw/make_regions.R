not_split <- readr::read_csv("./data-raw/files/town_region_lookup.csv") %>%
  dplyr::filter(!is.na(region))

regions <- split(not_split, not_split$region) %>%
  purrr::map(dplyr::pull, town)

usethis::use_data(regions, overwrite = T)
