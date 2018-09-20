# make ct_xwalk from LODES
url <- "https://lehd.ces.census.gov/data/lodes/LODES7/ct/ct_xwalk.csv.gz"
xwalk <- readr::read_csv(url) %>%
  dplyr::select(block = tabblk2010, block_grp = bgrp, tract = trct, town = ctycsubname, town_fips = ctycsub) %>%
  camiller::town_names(town) %>%
  dplyr::distinct() %>%
  dplyr::filter(stringr::str_detect(town_fips, "^09")) %>%
  dplyr::filter(tract != "09001990000")

# edit 9/20: filter so tracts only shown for town they overlap with most. A few tracts were listed for more than 1 town

dupes <- xwalk %>%
  dplyr::distinct(tract, town) %>%
  dplyr::group_by(tract) %>%
  dplyr::mutate(n = dplyr::n()) %>%
  dplyr::filter(n > 1)

dupe_town_sf <- town_sf %>% dplyr::filter(name %in% dupes$town)
dupe_tract_sf <- tract_sf %>% dplyr::filter(name %in% dupes$tract)

no_dupes <- dupes %>%
  dplyr::ungroup() %>%
  split(.$tract) %>%
  purrr::map(dplyr::pull, town) %>%
  purrr::imap_dfr(function(towns, tract) {
    dupe_tract_sf %>%
      dplyr::filter(name == tract) %>%
      sf::st_intersection(dupe_town_sf) %>%
      dplyr::mutate(area = sf::st_area(geometry)) %>%
      dplyr::arrange(desc(area)) %>%
      dplyr::slice(1) %>%
      dplyr::select(tract = name, town = name.1) %>%
      sf::st_set_geometry(NULL)
  })

tract2town <- xwalk %>%
  dplyr::distinct(tract, town) %>%
  dplyr::group_by(tract) %>%
  dplyr::mutate(n = n()) %>%
  dplyr::filter(n == 1) %>%
  dplyr::ungroup() %>%
  dplyr::select(-n) %>%
  dplyr::bind_rows(no_dupes)

usethis::use_data(xwalk, overwrite = T)
usethis::use_data(tract2town, overwrite = T)
