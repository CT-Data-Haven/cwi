nhv_tracts <- readr::read_csv("./data-raw/files/nhv_neighborhood_tracts.csv") %>%
  dplyr::mutate(tract = as.character(tract))

usethis::use_data(nhv_tracts)
