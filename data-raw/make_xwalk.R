# make ct_xwalk from LODES
url <- "https://lehd.ces.census.gov/data/lodes/LODES7/ct/ct_xwalk.csv.gz"
xwalk <- readr::read_csv(url) %>%
  dplyr::select(block = tabblk2010, block_grp = bgrp, tract = trct, town = ctycsubname, town_fips = ctycsub) %>%
  camiller::town_names(town) %>%
  dplyr::distinct() %>%
  dplyr::filter(stringr::str_detect(town_fips, "^09"))

usethis::use_data(xwalk, overwrite = T)
