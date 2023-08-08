# shapefiles of county subdivisions and census designated places
town <- tigris::county_subdivisions(state = "09", cb = T, class = "sf") |>
  dplyr::select(town_geoid = GEOID, town = NAME, geometry)
cdp <- tigris::places(state = "09", cb = T, class = "sf") |>
  dplyr::select(cdp_geoid = GEOID, place = NAME, geometry)

# only reason I can join and keep just the largest intersection is because I know that every CDP is almost entirely within a single town. Otherwise I'd need to find shares for CDPs split between towns.
# running list of manual adds
manual <- tibble::tribble(
  ~cdp_geoid, ~place,    ~town_geoid,  ~town,
  NA,         "Oakdale", "0901148900", "Montville"
)

# there are 89 CDPs whose names aren't town names
village2town <- cdp |>
  dplyr::anti_join(tibble::as_tibble(town), by = c("place" = "town")) |>
  sf::st_join(town, largest = T) |>
  sf::st_set_geometry(NULL) |>
  tibble::as_tibble() |>
  dplyr::bind_rows(manual) |>
  dplyr::arrange(place)

usethis::use_data(village2town, overwrite = TRUE)
