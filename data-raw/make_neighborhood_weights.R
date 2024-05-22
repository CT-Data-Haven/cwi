# weighted by households
# use xwalk to assign blocks to tracts---need to avoid errors in neighborhood
# boundaries as much as possible
# previously had an error where spatial joins had tracts assigned to wrong towns
# for nhv manually move long wharf to hill
# for hartford drop north meadows

# for 2022 switch to COGs, need to add COG-based fips codes as another column
sf::sf_use_s2(FALSE)
min_hh <- 3
nhoods <- list(bridgeport = bridgeport_sf,
               new_haven  = new_haven_sf,
               hartford   = hartford_sf,
               stamford   = stamford_sf) |>
  dplyr::bind_rows(.id = "city") |>
  dplyr::mutate(name = dplyr::recode(name, "Long Wharf" = "Hill")) |>
  dplyr::mutate(town = coalesce(town, city) |>
                  stringr::str_replace_all("_", " ") |>
                  stringr::str_to_title()) |>
  dplyr::filter(!name %in% c("North Meadows"))

hh20 <- tigris::blocks(state = "09", year = 2020, refresh = FALSE) |>
  janitor::clean_names() |>
  dplyr::filter(aland20 > 0) |>
  dplyr::select(block = geoid20, hh = housing20) |>
  dplyr::left_join(dplyr::select(cwi::xwalk, block, tract, town), by = "block")

# assign each block to 1 neighborhood
block2nhood <- hh20 |>
  sf::st_join(nhoods, left = TRUE, largest = TRUE) |>
  # check that town it's assigned to is correct and in set of cities
  dplyr::filter(town.x == town.y) |>
  sf::st_drop_geometry()

tract_pops <- block2nhood |>
  dplyr::group_by(city, town = town.x, tract) |>
  dplyr::summarise(tract_hh = sum(hh))

tract2nhood <- block2nhood |>
  dplyr::group_by(city, town = town.x, name, tract) |>
  dplyr::summarise(inter_hh = sum(hh)) |>
  dplyr::ungroup() |>
  dplyr::left_join(tract_pops, by = c("city", "town", "tract")) |>
  dplyr::mutate(weight = round(inter_hh / tract_hh, digits = 3)) |>
  dplyr::filter(weight > 0.01) |>
  dplyr::left_join(dplyr::distinct(cwi::xwalk, tract, tract_cog), by = "tract") |>
  dplyr::select(city, town, name, geoid = tract, geoid_cog = tract_cog, weight)

# sanity check:
# tract2nhood |>
#   dplyr::left_join(cwi::tract_sf, by = c("geoid" = "name")) |>
#   sf::st_as_sf() |>
#   split(~city) |>
#   purrr::map(sf::st_geometry) |>
#   purrr::map(plot)

out <- tract2nhood |>
  split(~city) |>
  purrr::map(janitor::remove_constant) |>
  rlang::set_names(\(x) paste(x, "tracts", sep = "_"))

# dropping block groups for now, but can add back in if we want
# block2nhood |>
#   dplyr::group_by(city, town, bgrp, name) |>
#   dplyr::summarise(hh = sum(hh)) |>
#   dplyr::mutate(weight = round(hh / sum(hh), 3))

# wow can't believe i'm doing list2env
list2env(tract2nhood, .GlobalEnv)
usethis::use_data(bridgeport_tracts,
                  hartford_tracts,
                  new_haven_tracts,
                  stamford_tracts,
                  overwrite = TRUE)
