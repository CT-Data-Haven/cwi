# WRITE: zip2town
# READ: data-raw/files/zip2town.csv

zip2town <- readr::read_csv("./data-raw/files/zip2town.csv", col_types = "ccddddc") |>
  dplyr::select(zip, town_geoid, town, tidyselect::everything())

usethis::use_data(zip2town, overwrite = TRUE)
