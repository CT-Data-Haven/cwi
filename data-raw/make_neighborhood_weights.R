# WRITE: bridgeport_tracts hartford_tracts new_haven_tracts stamford_tracts

sf::sf_use_s2(FALSE)
# weighted by households
# use xwalk to assign blocks to tracts---need to avoid errors in neighborhood
# boundaries as much as possible
# previously had an error where spatial joins had tracts assigned to wrong towns
# for nhv manually move long wharf to hill
# for hartford drop north meadows
# combine 2020, 2019 in one script

# for 2022 switch to COGs, need to add COG-based fips codes as another column
sf::sf_use_s2(FALSE)
min_hh <- 3
nhoods <- list(
    bridgeport = cwi::bridgeport_sf,
    new_haven = cwi::new_haven_sf,
    hartford = cwi::hartford_sf,
    stamford = cwi::stamford_sf
) |>
    dplyr::bind_rows(.id = "city") |>
    dplyr::mutate(name = dplyr::recode(name, "Long Wharf" = "Hill")) |>
    dplyr::mutate(town = dplyr::coalesce(town, city) |>
        stringr::str_replace_all("_", " ") |>
        stringr::str_to_title()) |>
    dplyr::filter(!name %in% c("North Meadows"))

# 2020 shapefile includes pop & households
hh20 <- tigris::blocks(state = "09", year = 2020, refresh = FALSE) |>
    janitor::clean_names() |>
    dplyr::filter(aland20 > 0, housing20 > 0) |>
    dplyr::select(block = geoid20, hh = housing20) |>
    dplyr::left_join(dplyr::select(cwi::xwalk, block, tract, town), by = "block")

# 2010 shapefile doesn't
# no longer working without county
counties <- tidycensus::fips_codes |>
    dplyr::filter(
        state == "CT",
        grepl("^0", county_code)
    )
hh10 <- purrr::map(counties$county_code, function(cty) {
    tidycensus::get_decennial("block", variables = c(hh10 = "H003001"), year = 2010, sumfile = "sf1", state = "09", county = cty, geometry = TRUE, keep_geo_vars = TRUE, cache_table = TRUE)
}) |>
    dplyr::bind_rows() |>
    janitor::clean_names() |>
    dplyr::filter(aland10 > 0, value > 0) |>
    dplyr::select(block10 = geoid, hh = value) |>
    # use towns since don't have xwalk for old geos
    sf::st_join(cwi::town_sf |> dplyr::select(town = name), left = FALSE, largest = TRUE)

# assign each block to 1 neighborhood
block2nhood <- hh20 |>
    sf::st_join(nhoods, left = TRUE, largest = TRUE) |>
    # check that town it's assigned to is correct and in set of cities
    dplyr::filter(town.x == town.y) |>
    sf::st_drop_geometry()

block2nhood10 <- hh10 |>
    sf::st_join(nhoods, left = TRUE, largest = TRUE) |>
    dplyr::filter(town.x == town.y) |>
    dplyr::mutate(tract10 = substr(block10, 1, 11)) |>
    sf::st_drop_geometry()


# tract pops for denominators
tract_pops <- block2nhood |>
    dplyr::group_by(city, town = town.x, tract) |>
    dplyr::summarise(tract_hh = sum(hh)) |>
    dplyr::filter(tract_hh >= min_hh)

tract_pops10 <- block2nhood10 |>
    dplyr::group_by(city, town = town.x, tract10) |>
    dplyr::summarise(tract_hh = sum(hh)) |>
    dplyr::filter(tract_hh >= min_hh)

tract2nhood <- block2nhood |>
    dplyr::group_by(city, town = town.x, name, tract) |>
    dplyr::summarise(inter_hh = sum(hh)) |>
    dplyr::ungroup() |>
    dplyr::left_join(tract_pops, by = c("city", "town", "tract")) |>
    dplyr::mutate(weight = round(inter_hh / tract_hh, digits = 3)) |>
    dplyr::filter(weight > 0.01) |>
    dplyr::left_join(dplyr::distinct(cwi::xwalk, tract, tract_cog), by = "tract") |>
    dplyr::select(city, town, name, geoid = tract, geoid_cog = tract_cog, weight)

tract2nhood10 <- block2nhood10 |>
    dplyr::group_by(city, town = town.x, name, tract10) |>
    dplyr::summarise(inter_hh = sum(hh)) |>
    dplyr::ungroup() |>
    dplyr::left_join(tract_pops10, by = c("city", "town", "tract10")) |>
    dplyr::mutate(weight = round(inter_hh / tract_hh, digits = 3)) |>
    dplyr::filter(weight > 0.01) |>
    dplyr::select(city, town, name, geoid10 = tract10, weight)

# sanity check:
# tract2nhood |>
#   dplyr::left_join(cwi::tract_sf, by = c("geoid" = "name")) |>
#   sf::st_as_sf() |>
#   split(~city) |>
#   purrr::map(sf::st_geometry) |>
#   purrr::map(plot)
# tract2nhood10 |>
#   dplyr::left_join(cwi::tract_sf19, by = c("geoid10" = "name")) |>
#   sf::st_as_sf() |>
#   split(~city) |>
#   purrr::map(sf::st_geometry) |>
#   purrr::map(plot)

out <- tract2nhood |>
    split(~city) |>
    # purrr::map(janitor::remove_constant) |>
    purrr::map(function(df) {
        if (length(unique(df$town)) == 1) {
            df$town <- NULL
        }
        dplyr::select(df, -city)
    }) |>
    rlang::set_names(\(x) paste(x, "tracts", sep = "_"))
out10 <- tract2nhood10 |>
    split(~city) |>
    # purrr::map(janitor::remove_constant) |>
    purrr::map(function(df) {
        if (length(unique(df$town)) == 1) {
            df$town <- NULL
        }
        dplyr::select(df, -city)
    }) |>
    rlang::set_names(\(x) paste(x, "tracts19", sep = "_"))

# dropping block groups for now, but can add back in if we want
# block2nhood |>
#   dplyr::group_by(city, town, bgrp, name) |>
#   dplyr::summarise(hh = sum(hh)) |>
#   dplyr::mutate(weight = round(hh / sum(hh), 3))

# wow can't believe i'm doing list2env
list2env(out, .GlobalEnv)
list2env(out10, .GlobalEnv)
usethis::use_data(bridgeport_tracts,
    hartford_tracts,
    new_haven_tracts,
    stamford_tracts,
    overwrite = TRUE
)
usethis::use_data(bridgeport_tracts19,
    hartford_tracts19,
    new_haven_tracts19,
    stamford_tracts19,
    overwrite = TRUE
)
