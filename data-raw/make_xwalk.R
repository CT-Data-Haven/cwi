# make ct_xwalk from LODES
# updating 12/8/2020: there's one fewer tract now--xwalk data got updated recently. Gone is 09011990100 from Old Lyme
# 09011980000 is split btw Ledyard & Groton (and therefore NL north & south pumas)--looks like it's pretty much just the sub base
# also adding in PUMAs based on shapefile--joining with towns instead of tracts, since afaik they're designated based on towns
puma_sf <- tigris::pumas("09", cb = TRUE, year = 2018, class = "sf") %>%
  dplyr::select(puma_fips = GEOID10, puma = NAME10) %>%
  dplyr::mutate(puma = stringr::str_remove(puma, " Towns?$"))

town2puma <- sf::st_join(town_sf, puma_sf, join = st_intersects,
                         left = TRUE, largest = TRUE, suffix = c("_town", "_puma")) %>%
  sf::st_drop_geometry() %>%
  dplyr::select(town = name, puma, puma_fips)

# filter so tracts only shown for town they overlap with most. A few tracts were listed for more than 1 town
tract2town <- sf::st_join(tract_sf, town_sf, join = st_intersects,
            left = TRUE, largest = TRUE, suffix = c("_tract", "_town")) %>%
  sf::st_drop_geometry() %>%
  dplyr::select(tract = name_tract, town = name_town) %>%
  dplyr::as_tibble()

# drop if no associated town
xwalk_read <- readr::read_csv("https://lehd.ces.census.gov/data/lodes/LODES7/ct/ct_xwalk.csv.gz", col_types = readr::cols(.default = "c")) %>%
  dplyr::filter(stringr::str_detect(ctycsub, "^09"),
                trct != "09001990000") %>%
  town_names(ctycsubname)

blocks <- xwalk_read %>%
  dplyr::select(block = tabblk2010, block_grp = bgrp, tract = trct)

# more roundabout but keeps fewer weird artifacts (hopefully)
xwalk <- # block, block_grp, tract, town, town_fips, county, county_fips, msa, msa_fips, puma, puma_fips
  xwalk_read %>%
  dplyr::select(town = ctycsubname, town_fips = ctycsub, county = ctyname, county_fips = cty, msa = cbsaname, msa_fips = cbsa) %>%
  dplyr::distinct() %>%
  dplyr::left_join(tract2town, by = "town") %>%
  dplyr::left_join(town2puma, by = "town") %>%
  dplyr::left_join(blocks, by = "tract") %>%
  dplyr::mutate(county = stringr::str_remove(county, ", CT")) %>%
  dplyr::select(block, block_grp, tract, town, town_fips, county, county_fips, msa, msa_fips, puma, puma_fips)

usethis::use_data(xwalk, overwrite = TRUE)
usethis::use_data(tract2town, overwrite = TRUE)


