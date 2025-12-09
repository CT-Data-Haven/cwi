# WRITE: village2town
# 2010 to 2020 increased by like 80 CDPs, many are much smaller than towns
# so rewriting for 2020 with block-based population weights
# since geometries need to be more precise now, can't use cb shapes
sf::sf_use_s2(FALSE)

sf_with_rownames <- function(df, name_col = "name") {
    df <- as.data.frame(df)
    df <- tibble::column_to_rownames(df, name_col)
    df <- sf::st_as_sf(df)
    df
}

pop_sf <- list(town = "county subdivision", place = "place", block = "block") |>
    purrr::map(
        tidycensus::get_decennial,
        variables = "P1_001N",
        year = 2020,
        state = "09",
        sumfile = "dhc",
        geometry = TRUE,
        cache_table = TRUE,
        cb = FALSE
    ) |>
    purrr::map(cwi:::clean_names) |>
    purrr::map(sf::st_transform, 2234)
pop_sf$town <- dplyr::select(pop_sf$town, town = name, town_pop = value) |>
    cwi::town_names(town)
pop_sf$place <- dplyr::select(
    pop_sf$place,
    place = name,
    place_geoid = geoid,
    place_pop = value
) |>
    dplyr::mutate(place = stringr::str_remove(place, ", [\\w\\s]+$"))
pop_sf$block <- dplyr::select(pop_sf$block, block = geoid, block_pop = value)
# pop_sf <- purrr::map(pop_sf, sf_with_rownames)

# assign each block to just one place
min_sqft <- units::set_units(1e3, "US_survey_foot^2")
block_place <- sf::st_intersection(pop_sf$block, pop_sf$place) |>
    sf::st_collection_extract("POLYGON") |>
    dplyr::filter(sf::st_dimension(geometry) == 2) |>
    dplyr::filter(sf::st_area(geometry) >= min_sqft)
block_place_wts <- sf::st_interpolate_aw(
    pop_sf$block[, "block_pop"],
    block_place,
    extensive = TRUE,
    keep_na = TRUE
)
village2town <- block_place |>
    dplyr::select(block, place, place_geoid, place_pop) |>
    cbind(sf::st_drop_geometry(block_place_wts)) |>
    sf::st_join(pop_sf$town, left = TRUE, largest = TRUE) |>
    sf::st_drop_geometry() |>
    dplyr::group_by(town, town_pop, place, place_geoid, place_pop) |>
    dplyr::summarise(overlap_pop = sum(block_pop)) |>
    dplyr::mutate(place_wt = overlap_pop / place_pop) |>
    dplyr::ungroup() |>
    dplyr::select(
        town,
        place,
        place_geoid,
        town_pop,
        place_pop,
        overlap_pop,
        place_wt
    ) |>
    dplyr::mutate(
        overlap_pop = round(overlap_pop, digits = 0),
        place_wt = round(place_wt, digits = 3)
    )


# was keeping manual add-ons but dropping
# only had Oakdale (Montville)

usethis::use_data(village2town, overwrite = TRUE)
