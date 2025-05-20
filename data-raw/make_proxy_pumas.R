# WRITE: proxy_pumas
# need to do this a little awkwardly to make sure PUMAs can be included in multiple regions, e.g. for county-based, Ansonia PUMA is both GNH & Valley
# include regions for county-based, regions and counties for COG-based
town_puma <- list(
    county = cwi::xwalk |> dplyr::distinct(town, puma_fips) |> dplyr::rename(puma = puma_fips),
    cog = cwi::xwalk |> dplyr::distinct(town, puma_fips_cog) |> dplyr::rename(puma = puma_fips_cog)
) |>
    dplyr::bind_rows(.id = "puma_type") |>
    dplyr::mutate(puma_type = forcats::as_factor(puma_type))

town_county <- dplyr::distinct(cwi::xwalk, town, county) |>
    dplyr::rename(region = county)

reg_df <- cwi::regions[c("Greater New Haven", "Greater Hartford", "Greater Waterbury", "Lower Naugatuck Valley", "Greater Bridgeport")] |>
    tibble::enframe(name = "region", value = "town") |>
    tidyr::unnest(town) |>
    dplyr::bind_rows(town_county)

pops <- tidyr::expand_grid(
    puma_type = tibble::enframe(list(county = 2021, cog = 2022), name = "puma_type", value = "year") |> tidyr::unnest(year),
    geo = c("county subdivision", "puma")
) |>
    tidyr::unnest(puma_type) |>
    dplyr::mutate(puma_type = forcats::as_factor(puma_type)) |>
    dplyr::mutate(data = purrr::pmap(list(puma_type, year, geo), function(puma_type, year, geo) tidycensus::get_acs(geo, variables = c(pop = "B01003_001", hh = "B25003_001"), state = "09", year = year))) |>
    dplyr::mutate(data = purrr::map(data, cwi:::clean_names)) |>
    dplyr::mutate(data = purrr::modify_at(data, geo == "county subdivision", cwi::town_names, name)) |>
    dplyr::mutate(data = purrr::modify_at(data, geo == "puma", \(x) dplyr::select(x, -name) |> dplyr::rename(name = geoid))) |>
    dplyr::mutate(data = purrr::map(data, tidyr::pivot_wider, id_cols = name, names_from = variable, values_from = estimate)) |>
    dplyr::mutate(geo = forcats::fct_recode(geo, town = "county subdivision")) |>
    tidyr::unnest(data) |>
    split(~geo) |>
    purrr::map(tidyr::pivot_wider, id_cols = c(puma_type, name, year), names_from = geo, values_from = pop:hh)

proxy_pumas <- reg_df |>
    dplyr::left_join(town_puma, by = "town", relationship = "many-to-many") |>
    dplyr::left_join(pops$town, by = c("town" = "name", "puma_type"), relationship = "many-to-many") |>
    dplyr::select(-tidyselect::matches("^geo_")) |>
    dplyr::group_by(region, puma_type, year, puma) |>
    dplyr::summarise(dplyr::across(pop_town:hh_town, sum)) |>
    dplyr::left_join(pops$puma, by = c("puma_type", "puma" = "name", "year")) |>
    dplyr::mutate(
        pop_weight = pop_town / pop_puma,
        hh_weight = hh_town / hh_puma
    ) |>
    dplyr::filter(!(grepl(" County", region) & puma_type == "county")) |>
    dplyr::ungroup() |>
    dplyr::select(puma_type, puma, region, pop = pop_town, hh = hh_town, pop_weight, hh_weight) |>
    split(~puma_type) |>
    purrr::map(dplyr::select, -puma_type)

usethis::use_data(proxy_pumas, overwrite = TRUE)
