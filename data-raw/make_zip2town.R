sf::sf_use_s2(FALSE)

lookup <- readr::read_delim("https://www2.census.gov/geo/docs/maps-data/data/rel2022/acs22_cousub22_zcta520_st09.txt",
    delim = "|", col_types = readr::cols(.default = "c")
) |>
    dplyr::select(town = NAMELSAD_COUSUB_22, zip = GEOID_ZCTA5_20, inter_area = AREALAND_PART) |>
    dplyr::filter(
        !grepl("County subdivisions", town),
        !is.na(zip)
    ) |>
    dplyr::mutate(town = stringr::str_remove(town, " town$"))

town_sf <- tigris::county_subdivisions(state = "09", cb = FALSE, year = 2022) |>
    dplyr::filter(ALAND > 0) |>
    dplyr::select(name = NAME) |>
    sf::st_transform(2234)
zip_sf <- tigris::zctas(cb = FALSE, starts_with = "06", year = 2022) |>
    dplyr::filter(ALAND20 > 0) |>
    dplyr::select(name = GEOID20) |>
    sf::st_transform(2234)
block_pop <- tidycensus::get_decennial("block",
    variables = c(pop = "P1_001N", hh = "H4_001N"),
    state = "09", year = 2020, sumfile = "dhc",
    geometry = TRUE, output = "wide"
) |>
    janitor::clean_names() |>
    dplyr::select(-name) |>
    # dplyr::filter(pop > 0) |>
    sf::st_transform(2234)

block_town <- block_pop |>
    sf::st_drop_geometry() |>
    dplyr::inner_join(dplyr::distinct(cwi::xwalk, block, town), by = c("geoid" = "block")) |>
    dplyr::rename(name = town)
# takes too long to calc area, get largest overlap for every block---only do for blocks with more than one overlap
block_zip_mtx <- sf::st_intersects(block_pop, zip_sf)

block_zip_multi <- block_pop[lengths(block_zip_mtx) > 1, ] |>
    sf::st_join(zip_sf, left = FALSE, largest = TRUE)
block_zip_single <- block_pop |>
    dplyr::mutate(zip_idx = as.list(block_zip_mtx)) |>
    tidyr::unnest(zip_idx) |>
    dplyr::mutate(name = zip_sf$name[zip_idx]) |>
    dplyr::select(-zip_idx) |>
    dplyr::filter(!geoid %in% block_zip_multi$geoid)
block_zip <- dplyr::bind_rows(block_zip_multi, block_zip_single)

block_dfs <- dplyr::bind_rows(town = block_town, zip = block_zip, .id = "level") |>
    sf::st_drop_geometry() |>
    tidyr::pivot_wider(id_cols = c(geoid, pop, hh), names_from = level, values_from = name) |>
    dplyr::filter(!is.na(town))

town_pop <- block_dfs |>
    dplyr::group_by(town) |>
    dplyr::summarise(dplyr::across(pop:hh, list(town = sum), .names = "{fn}_{col}")) |>
    dplyr::filter(!is.na(town))
zip_pop <- block_dfs |>
    dplyr::group_by(zip) |>
    dplyr::summarise(dplyr::across(pop:hh, list(zip = sum), .names = "{fn}_{col}")) |>
    dplyr::filter(!is.na(zip))

# semi join to keep just overlaps that are in lookup--misses a few small ones
zip2town <- block_dfs |>
    dplyr::inner_join(town_pop, by = "town") |>
    dplyr::inner_join(zip_pop, by = "zip") |>
    dplyr::group_by(town, zip, town_pop, town_hh, zip_pop, zip_hh) |>
    dplyr::summarise(dplyr::across(pop:hh, list(inter = sum), .names = "{fn}_{col}")) |>
    dplyr::ungroup() |>
    dplyr::semi_join(lookup, by = c("zip", "town")) |>
    dplyr::rename(town_name = town, zip_name = zip) |>
    tidyr::pivot_longer(matches("(_pop|_hh)"), names_to = c(".value", "group"), names_sep = "_") |>
    dplyr::mutate(
        pct_of_town = round(inter / town, digits = 4),
        pct_of_zip = round(inter / zip, digits = 4)
    ) |>
    tidyr::pivot_wider(id_cols = town_name:zip_name, names_from = group, values_from = c(dplyr::matches("(inter|pct)"))) |>
    dplyr::rename(town = town_name, zip = zip_name)

usethis::use_data(zip2town, overwrite = TRUE)
