# make ct_xwalk from LODES
# updating 12/8/2020: there's one fewer tract now--xwalk data got updated recently. Gone is 09011990100 from Old Lyme
# also adding in PUMAs based on shapefile
puma_sf <- tigris::pumas("09", cb = TRUE, year = 2018, class = "sf") %>%
  dplyr::select(puma_fips = GEOID10, puma = NAME10) %>%
  dplyr::mutate(puma = stringr::str_remove(puma, " Towns?$"))

tract2puma <- sf::st_join(tract_sf, puma_sf, join = st_intersects,
            left = TRUE, largest = TRUE, suffix = c("_tract", "_puma")) %>%
  sf::st_drop_geometry() %>%
  dplyr::select(tract = name, puma, puma_fips)

xwalk <- readr::read_csv("https://lehd.ces.census.gov/data/lodes/LODES7/ct/ct_xwalk.csv.gz") %>%
  dplyr::select(block = tabblk2010, block_grp = bgrp, tract = trct, town = ctycsubname, town_fips = ctycsub, county = ctyname, county_fips = cty, msa = cbsaname, msa_fips = cbsa) %>%
  town_names(town) %>%
  dplyr::distinct() %>%
  dplyr::filter(stringr::str_detect(town_fips, "^09")) %>%
  dplyr::filter(tract != "09001990000") %>%
  dplyr::left_join(tract2puma, by = "tract")

# filter so tracts only shown for town they overlap with most. A few tracts were listed for more than 1 town
tract2town <- sf::st_join(tract_sf, town_sf, join = st_intersects,
            left = TRUE, largest = TRUE, suffix = c("_tract", "_town")) %>%
  sf::st_drop_geometry() %>%
  dplyr::select(tract = name_tract, town = name_town) %>%
  dplyr::as_tibble()

usethis::use_data(xwalk, overwrite = TRUE)
usethis::use_data(tract2town, overwrite = TRUE)
