zip2town <- readr::read_csv("./files/zip2town.csv", col_types = "ccddddc") %>%
  dplyr::select(zip, town_geoid, town, tidyselect::everything())

usethis::use_data(zip2town, overwrite = TRUE)
