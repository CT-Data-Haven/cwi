# make sf objects of towns, neighborhoods
sf::sf_use_s2(FALSE)
town_sf <- tigris::county_subdivisions(state = "09", cb = TRUE, class = "sf", year = 2020) |>
  dplyr::select(name = NAME, GEOID, geometry) |>
  dplyr::arrange(GEOID)

tract_sf <- tigris::tracts(state = "09", cb = TRUE, class = "sf", year = 2020) |>
  dplyr::select(name = GEOID, geometry)
tract_sf19 <- tigris::tracts(state = "09", cb = TRUE, class = "sf", year = 2019) |>
  dplyr::select(name = GEOID, geometry)

new_haven_sf <- sf::st_read("https://gist.githubusercontent.com/camille-s/c8cfa583ef22105e90d53ceb299f1a7b/raw/fc087f30ddb2658a05fb5408f1e9d5276b8a433d/nhv.json") |>
  dplyr::rename(name = neighborhood) |>
  dplyr::mutate(name = dplyr::recode(name, "Wooster Square/Mill River" = "Wooster Square")) |>
  sf::st_transform(sf::st_crs(tract_sf))


stamford_sf <- sf::st_read("https://gist.github.com/camille-s/7002148f77b0020f780f46127be5e9ea/raw/084af721d6dcf509b29c69b3425179fda0748f03/stamford.geojson") |>
  dplyr::select(name, geometry) |>
  sf::st_transform(sf::st_crs(tract_sf))


bridgeport_sf <- sf::st_read("https://gist.github.com/camille-s/c5e4f0178cfbf288af454016018f5173/raw/43faa412db577c4f770d861ab913116ccdb3d445/bpt_tract_neighborhoods.geojson") |>
  dplyr::select(name = Name, geometry) |>
  sf::st_cast("MULTIPOLYGON") |>
  sf::st_make_valid() |>
  sf::st_transform(sf::st_crs(tract_sf))


hartford_sf <- sf::st_read("https://gist.github.com/camille-s/9e9761b69a7c86bf6d7163cb73636f26/raw/3858f538d955c022b43e168e4c7cec316c2e437f/hfd_shape.json") |>
  dplyr::select(name = Neighborhood, town = Town, geometry) |>
  sf::st_set_crs(sf::st_crs(tract_sf)) |>
  sf::st_transform(sf::st_crs(tract_sf))


usethis::use_data(town_sf, overwrite = TRUE)
usethis::use_data(new_haven_sf, overwrite = TRUE)
usethis::use_data(stamford_sf, overwrite = TRUE)
usethis::use_data(bridgeport_sf, overwrite = TRUE)
usethis::use_data(hartford_sf, overwrite = TRUE)
usethis::use_data(tract_sf, overwrite = TRUE)
usethis::use_data(tract_sf19, overwrite = TRUE)

