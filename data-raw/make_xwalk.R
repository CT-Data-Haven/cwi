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
  dplyr::mutate(bgrp_ce = substring(block_grp, 6)) |> # drop later but use to join cog-based bgrps
  sf::st_drop_geometry() |>
  dplyr::select(block = geoid20, block_grp, tract, county_fips, tractce = tractce20, bgrp_ce)

pumas_sf <- list(puma20 = 2020, puma22 = 2022) |>
  purrr::map(\(x) tigris::pumas("09", year = x)) |>
  purrr::map(janitor::clean_names) |>
  purrr::map(dplyr::select, puma_fips = tidyselect::matches("geoid"), puma = tidyselect::matches("namelsad")) |>
  purrr::map(dplyr::mutate, puma = stringr::str_remove(puma, " Towns?")) |>
  purrr::map(dplyr::mutate, puma = stringr::str_remove(puma, " PUMA"))

town2pumas <- purrr::map(pumas_sf, \(x) sf::st_join(cwi::town_sf, x, join = sf::st_intersects,
                                                    left = TRUE, largest = TRUE)) |>
  purrr::map(sf::st_drop_geometry) |>
  purrr::map(dplyr::select, town = name, town_fips = GEOID, puma, puma_fips)
town2pumas$puma22 <- dplyr::rename(town2pumas$puma22, puma_cog = puma, puma_fips_cog = puma_fips)



msa_sf <- tigris::core_based_statistical_areas(cb = TRUE, year = 2020) |>
  janitor::clean_names() |>
  dplyr::filter(grepl("CT", name)) |>
  dplyr::select(msa = name, msa_fips = geoid)


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

# add new columns for cog-based fips--town, tract, block group, puma. blocks not updated as of yet
cog_fips <- list(town = tigris::county_subdivisions,
                 tract = tigris::tracts,
                 block_grp = tigris::block_groups) |>
  purrr::map(\(x) x(state = "09", year = 2022)) |>
  purrr::map(sf::st_drop_geometry) |>
  purrr::map(janitor::clean_names)
town_cog <- cog_fips$town |>
  dplyr::select(town_fips_cog = geoid, town = name)
tract_cog <- cog_fips$tract |>
  dplyr::select(tract_cog = geoid, tractce)
block_grp_cog <- cog_fips$block_grp |>
  dplyr::select(block_grp_cog = geoid) |>
  dplyr::mutate(bgrp_ce = substring(block_grp_cog, 6))


xwalk <- blocks |>
  dplyr::left_join(counties, by = "county_fips") |>
  dplyr::left_join(tract2town, by = "tract") |>
  dplyr::left_join(town2cog, by = "town") |>
  dplyr::left_join(town2msa, by = "town") |>
  dplyr::left_join(town2pumas$puma20, by = "town") |>
  dplyr::left_join(town2pumas$puma22, by = c("town", "town_fips")) |>
  dplyr::left_join(town_cog, by = "town") |>
  dplyr::left_join(tract_cog, by = "tractce") |>
  dplyr::left_join(block_grp_cog, by = "bgrp_ce") |>
  dplyr::select(block,
                block_grp, block_grp_cog,
                tract, tract_cog,
                town, town_fips, town_fips_cog,
                county, county_fips,
                cog, cog_fips,
                msa, msa_fips,
                puma, puma_fips, puma_fips_cog) |>
  dplyr::as_tibble()

colSums(is.na(xwalk))

usethis::use_data(xwalk, overwrite = TRUE)
usethis::use_data(tract2town, overwrite = TRUE)
