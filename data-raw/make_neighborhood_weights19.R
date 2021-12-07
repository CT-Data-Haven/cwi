sf::sf_use_s2(FALSE)
# same as other neighborhood weights, but need to make a copy reverted back to 2019
min_hh <- 3
counties <- sprintf("%03d", c(1, 3, 9))

block_sf <- tigris::blocks(state = "09", year = 2019) %>%
  janitor::clean_names() %>%
  dplyr::filter(aland10 > 0, countyfp10 %in% counties) %>%
  dplyr::mutate(tract = paste0(statefp10, countyfp10, tractce10)) %>%
  dplyr::select(block = geoid10, tract)
tract_sf <- tigris::tracts(state = "09", cb = TRUE, year = 2019) %>%
  janitor::clean_names() %>%
  dplyr::filter(aland > 0, countyfp %in% counties) %>%
  dplyr::select(tract = geoid)

# from other weights script
min_area <- 3.5e4

# occupied housing units
hh10 <- tidycensus::get_decennial("block", variables = "H003002", sumfile = "sf1", state = "09", county = counties, year = 2010) %>%
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
  dplyr::left_join(hh10, by = "block") %>%
  dplyr::filter(hh >= min_hh)

tract2nhood19 <- block2nhood %>%
  dplyr::group_by(city, town, tract, name) %>%
  dplyr::summarise(hh = sum(hh)) %>%
  dplyr::mutate(weight = round(hh / sum(hh), 3)) %>%
  dplyr::ungroup() %>%
  dplyr::select(-hh) %>%
  split(.$city) %>%
  purrr::map(dplyr::select, town, name, geoid = tract, weight) %>%
  purrr::map(janitor::remove_empty, "cols") %>%
  rlang::set_names(~paste(., "tracts19", sep = "_"))

list2env(tract2nhood19, .GlobalEnv)
usethis::use_data(bridgeport_tracts19,
                  hartford_tracts19,
                  new_haven_tracts19,
                  stamford_tracts19,
                  overwrite = TRUE)
