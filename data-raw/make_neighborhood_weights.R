sf::sf_use_s2(FALSE)
# weighted by households
# for redistricting data, that's occupied housing units H1_002N--should be same
# assign each block to tract with majority of its area (i.e. 1 tract per block)
# for nhv manually move long wharf to hill
# for hartford drop north meadows
# switch to using regular tiger data with tigris
min_hh <- 3
counties <- sprintf("%03d", c(1, 3, 9))

block_sf <- tigris::blocks(state = "09", year = 2020) %>%
  janitor::clean_names() %>%
  dplyr::filter(aland20 > 0, countyfp20 %in% counties) %>%
  dplyr::mutate(tract = paste0(statefp20, countyfp20, tractce20)) %>%
  dplyr::select(block = geoid20, tract)
tract_sf <- tigris::tracts(state = "09", cb = TRUE, year = 2020) %>%
  janitor::clean_names() %>%
  dplyr::filter(aland > 0, countyfp %in% counties) %>%
  dplyr::select(tract = geoid)

# find average city block size, use as minimum for overlap (maybe half the area of the median block?)
# block_sf %>%
#   dplyr::filter(
#     sf::st_intersects(., dplyr::bind_rows(list(bridgeport_sf, new_haven_sf, hartford_sf, stamford_sf))) %>%
#       purrr::map_lgl(~length(.) > 0)
#   ) %>%
#   dplyr::mutate(area = sf::st_area(geometry) %>%
#                   units::set_units("ft2"),
#                 half = area / 4) %>%
#   dplyr::filter(as.numeric(area) < 5e6 & sf::st_dimension(geometry) > 1) %>% # drop west rock
#   sf::st_drop_geometry() %>%
#   dplyr::select(area:half) %>%
#   summary()
# 25th percentile of a half-block's area is about 35k sqft
min_area <- 3.5e4

# only need cities for fairfield, hartford & new haven counties
hh20 <- tidycensus::get_decennial("block", table = "H1", sumfile = "pl", year = 2020,
                                  state = "09", county = counties) %>%
  dplyr::filter(variable == "H1_002N") %>%
  dplyr::select(block = GEOID, hh = value)

nhoods <- tibble::lst(bridgeport = bridgeport_sf, new_haven = new_haven_sf, hartford = hartford_sf, stamford = stamford_sf) %>%
  dplyr::bind_rows(.id = "city") %>%
  dplyr::mutate(name = dplyr::recode(name, "Long Wharf" = "Hill")) %>%
  dplyr::filter(!name %in% c("North Meadows"))


block2town <- block_sf %>%
  sf::st_join(cwi::town_sf, largest = TRUE) %>%
  dplyr::select(-name:-GEOID)

block2nhood <- block2town %>%
  sf::st_intersection(nhoods) %>%
  dplyr::mutate(area = sf::st_area(geometry) %>%
                  units::set_units("ft2") %>%
                  as.numeric()) %>%
  sf::st_drop_geometry() %>%
  dplyr::arrange(area) %>%
  dplyr::group_by(block) %>%
  dplyr::filter(area == max(area), area > min_area) %>%
  dplyr::ungroup() %>%
  dplyr::left_join(hh20, by = "block") %>%
  dplyr::filter(hh >= min_hh)

tract2nhood <- block2nhood %>%
  dplyr::group_by(city, town, tract, name) %>%
  dplyr::summarise(hh = sum(hh)) %>%
  dplyr::mutate(weight = round(hh / sum(hh), 3)) %>%
  dplyr::ungroup() %>%
  dplyr::select(-hh) %>%
  split(.$city) %>%
  purrr::map(dplyr::select, town, name, geoid = tract, weight) %>%
  purrr::map(janitor::remove_empty, "cols") %>%
  rlang::set_names(~paste(., "tracts", sep = "_"))


# dropping block groups for now, but can add back in if we want
# block2nhood %>%
#   dplyr::group_by(city, town, bgrp, name) %>%
#   dplyr::summarise(hh = sum(hh)) %>%
#   dplyr::mutate(weight = round(hh / sum(hh), 3))

# wow can't believe i'm doing list2env
list2env(tract2nhood, .GlobalEnv)
usethis::use_data(bridgeport_tracts,
                  hartford_tracts,
                  new_haven_tracts,
                  stamford_tracts,
                  overwrite = TRUE)
