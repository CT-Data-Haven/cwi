# output: block, block_grp, tract, town, town_fips, county, county_fips, msa, msa_fips, puma, puma_fips
sf::sf_use_s2(FALSE)

county_equiv <- tidycensus::fips_codes |>
  dplyr::filter(state == "CT") |>
  dplyr::mutate(county_fips = paste0(state_code, county_code)) |>
  dplyr::select(county, county_fips)

counties <- county_equiv |>
  dplyr::filter(grepl("County$", county))
# should match what the census returns
cogs <- county_equiv |>
  dplyr::filter(!grepl("County$", county)) |>
  dplyr::rename(cog = county, cog_fips = county_fips) |>
  dplyr::mutate(cog = paste(cog, "COG"))

# no 2020 CB pumas yet
blocks <- tigris::blocks("09", year = 2020) |>
  janitor::clean_names() |>
  dplyr::filter(aland20 > 0) |>
  dplyr::mutate(county_fips = paste0(statefp20, countyfp20)) |>
  dplyr::mutate(tract = paste0(county_fips, tractce20)) |>
  dplyr::mutate(block_grp = substr(geoid20, 1, 12)) |>
  sf::st_drop_geometry() |>
  dplyr::select(block = geoid20, block_grp, tract, county_fips)

puma_sf <- tigris::pumas("09", cb = FALSE, year = 2020) |>
  janitor::clean_names() |>
  dplyr::select(puma = namelsad10, puma_fips = geoid10) |>
  dplyr::mutate(puma = stringr::str_remove(puma, " Towns?")) |>
  dplyr::mutate(puma = stringr::str_remove(puma, " PUMA"))

msa_sf <- tigris::core_based_statistical_areas(cb = TRUE, year = 2020) |>
  janitor::clean_names() |>
  dplyr::filter(grepl("CT", name)) |>
  dplyr::select(msa = name, msa_fips = geoid)

town2puma <- sf::st_join(cwi::town_sf, puma_sf, join = sf::st_intersects,
                         left = TRUE, largest = TRUE,
                         suffix = c("_town", "_puma")) |>
  sf::st_drop_geometry() |>
  dplyr::select(town = name, town_fips = GEOID, puma, puma_fips)

town2msa <- sf::st_join(cwi::town_sf, msa_sf, join = sf::st_intersects,
                        left = TRUE, largest = TRUE) |>
  sf::st_drop_geometry() |>
  dplyr::select(town = name, msa, msa_fips)

tract2town <- sf::st_join(cwi::tract_sf, cwi::town_sf, join = sf::st_intersects,
                          left = TRUE, largest = TRUE,
                          suffix = c("_tract", "_town")) |>
  sf::st_drop_geometry() |>
  dplyr::select(tract = name_tract, town = name_town) |>
  dplyr::as_tibble()

town2cog <- cwi::regions[grepl("COG$", names(cwi::regions))] |>
  tibble::enframe(name = "cog", value = "town") |>
  tidyr::unnest(town) |>
  dplyr::left_join(cogs, by = "cog")

# town FIPS changed to start with COG FIPS--add another column
town_new_fips <- tigris::county_subdivisions(state = "09", year = 2022) |>
  sf::st_drop_geometry() |>
  janitor::clean_names() |>
  dplyr::select(town_fips22 = geoid, town = name)

xwalk <- blocks |>
  dplyr::left_join(counties, by = "county_fips") |>
  dplyr::left_join(tract2town, by = "tract") |>
  dplyr::left_join(town2cog, by = "town") |>
  dplyr::left_join(town2msa, by = "town") |>
  dplyr::left_join(town2puma, by = "town") |>
  dplyr::left_join(town_new_fips, by = "town") |>
  dplyr::select(block, block_grp, tract, town, town_fips, town_fips22, county, county_fips, cog, cog_fips, msa, msa_fips, puma, puma_fips) |>
  dplyr::as_tibble()

colSums(is.na(xwalk))

usethis::use_data(xwalk, overwrite = TRUE)
usethis::use_data(tract2town, overwrite = TRUE)
