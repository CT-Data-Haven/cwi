# WRITE: regions
# READ: data-raw/files/town_region_lookup.csv

town2cog <- tigris::county_subdivisions(state = "09", year = 2022, cb = TRUE) |>
    sf::st_drop_geometry() |>
    dplyr::select(name = NAMELSADCO, town = NAME) |>
    dplyr::mutate(
        name = stringr::str_replace(name, "Planning Region", "COG")
    ) |>
    dplyr::mutate(town = stringr::str_remove(town, " town$")) |>
    dplyr::filter(!grepl("not defined", town))

town2reg <- readr::read_csv("./data-raw/files/town_region_lookup.csv") |>
    dplyr::filter(!is.na(region)) |>
    dplyr::select(name = region, town)

# add back in legacy counties
town2county <- cwi::xwalk |>
    dplyr::distinct(town, county) |>
    dplyr::rename(name = county) |>
    dplyr::anti_join(town2reg, by = "name")

regions <- dplyr::bind_rows(town2cog, town2reg, town2county) |>
    split(~name) |>
    purrr::map(dplyr::pull, town) |>
    purrr::map(sort)

usethis::use_data(regions, overwrite = TRUE)

# Capitol Region COG
# Connecticut Metro COG
# Lower Connecticut River Valley COG
# Naugatuck Valley COG
# Northeastern COG
# Northwest Hills COG
# South Central Regional COG
# Southeastern Connecticut COG
# Western Connecticut COG
