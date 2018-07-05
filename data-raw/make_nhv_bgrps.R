nhv_bgrps <- readr::read_csv("./data-raw/files/nhv_neighborhood_bgrps.csv", col_types = "cccdc") %>%
  dplyr::rename(name = neighborhood) %>%
  dplyr::select(name, geoid, tract, block_group, weight)

usethis::use_data(nhv_bgrps, overwrite = T)
