# need workaround for cases where tracts were written in scientific notation
nhv_tracts <- readr::read_csv("./data-raw/files/nhv_neighborhood_tracts.csv", col_types = "ccdc") %>%
  dplyr::select(name = neighborhood, geoid, tract, weight) %>%
  dplyr::mutate(tract = as.character(as.numeric(tract)))

usethis::use_data(nhv_tracts, overwrite = T)
