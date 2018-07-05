xwalk <- readr::read_csv("./data-raw/files/block2town.csv", col_types = "ccc")

block_pops_fc <- tidycensus::get_decennial(geography = "block", variables = "H0030001", state = "09", county = "01", year = 2010, sumfile = "sf1", geometry = T)
block_pops_hc <- tidycensus::get_decennial(geography = "block", variables = "H0030001", state = "09", county = "03", year = 2010, sumfile = "sf1", geometry = T)

stamford_shares <- block_pops_fc %>%
  dplyr::inner_join(xwalk %>% dplyr::filter(town == "Stamford"), by = c("GEOID" = "block")) %>%
  sf::st_join(sf::st_transform(stamford_sf, sf::st_crs(block_pops_fc)), left = F, largest = T) %>%
  dplyr::filter(value > 0) %>%
  sf::st_set_geometry(NULL) %>%
  dplyr::group_by(tract, name) %>%
  dplyr::summarise(households = sum(value)) %>%
  dplyr::mutate(share = round(households / sum(households), digits = 2)) %>%
  dplyr::ungroup()

bridgeport_shares <- block_pops_fc %>%
  dplyr::inner_join(xwalk %>% dplyr::filter(town == "Bridgeport"), by = c("GEOID" = "block")) %>%
  sf::st_join(sf::st_transform(bridgeport_sf, sf::st_crs(block_pops_fc)), left = F, largest = T) %>%
  dplyr::filter(value > 0) %>%
  sf::st_set_geometry(NULL) %>%
  dplyr::group_by(tract, name) %>%
  dplyr::summarise(households = sum(value)) %>%
  dplyr::mutate(share = round(households / sum(households), digits = 2)) %>%
  dplyr::ungroup()

hartford_shares <- block_pops_hc %>%
  dplyr::inner_join(xwalk %>% dplyr::filter(town %in% c("Hartford", "West Hartford")), by = c("GEOID" = "block")) %>%
  sf::st_join(sf::st_transform(hartford_sf, sf::st_crs(block_pops_hc)), left = F, largest = T) %>%
  dplyr::filter(value > 0) %>%
  sf::st_set_geometry(NULL) %>%
  dplyr::group_by(tract, name) %>%
  dplyr::summarise(households = sum(value)) %>%
  dplyr::filter(households > 50) %>%
  dplyr::mutate(share = round(households / sum(households), digits = 2)) %>%
  dplyr::ungroup()


usethis::use_data(stamford_shares, overwrite = T)
usethis::use_data(bridgeport_shares, overwrite = T)
usethis::use_data(hartford_shares, overwrite = T)
