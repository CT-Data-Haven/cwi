regions <- readr::read_csv("./files/town_region_lookup.csv") %>%
  dplyr::filter(!is.na(region)) %>%
  split(.$region)

use_data(regions, overwrite = T)
