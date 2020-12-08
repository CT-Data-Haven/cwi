# decennial API needs state-county-county sub hierarchy
counties_to_fetch <- function(st, counties) {
  if (!is.null(counties) & !identical(counties, "all")) {
    out <- counties
  } else {
    out <- tidycensus::fips_codes %>%
      dplyr::filter(state_code == st | state_name == st) %>%
      dplyr::pull(county)
  }
  return(out)
}

decennial_towns <- function(table, year, towns, counties, state, sumfile, key) {
  st <- state

  fetch <- counties_to_fetch(st = st, counties = counties) %>%
    purrr::map_dfr(function(county) {
      suppressMessages(tidycensus::get_decennial(geography = "county subdivision", table = table, year = year, state = st, county = county, sumfile = sumfile, key = key)) %>%
        dplyr::mutate(county = county)
    }) %>%
    town_names(NAME)

  if (!identical(towns, "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% towns)
  }
  fetch %>%
    dplyr::mutate(state = st)
}

decennial_counties <- function(table, year, counties, state, sumfile, key) {
  fetch <- suppressMessages(tidycensus::get_decennial(geography = "county", table = table, year = year, state = state, sumfile = sumfile, key = key)) %>%
    dplyr::mutate(NAME = stringr::str_extract(NAME, "^.+County")) %>%
    dplyr::mutate(state = state)

  if (!identical(counties, "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% counties | GEOID %in% counties)
  }
  fetch
}

decennial_tracts <- function(table, year, tracts, counties, state, sumfile, key) {
  fetch <- counties_to_fetch(st = state, counties = counties) %>%
    purrr::map_dfr(function(county) {
      suppressMessages(tidycensus::get_decennial(geography = "tract", table = table, year = year, state = state, county = county, sumfile = sumfile, key = key)) %>%
        dplyr::mutate(county = county)
    })

  if (!identical(tracts, "all")) {
    fetch <- fetch %>% dplyr::filter(GEOID %in% tracts)
  }
  fetch %>%
    dplyr::mutate(state = state)
}

decennial_state <- function(table, year, state, sumfile, key) {
  fetch <- suppressMessages(tidycensus::get_decennial(geography = "state", table = table, year = year, sumfile = sumfile, key = key)) %>%
    dplyr::filter(NAME == state | GEOID == state)
  fetch
}

decennial_regions <- function(table, year, regions, state, sumfile, key) {
  fetch_towns <- decennial_towns(table, year, towns = "all", counties = "all", state, sumfile, key)

  regions %>%
    purrr::imap_dfr(function(region, region_name) {
      fetch_towns %>%
        dplyr::filter(NAME %in% region) %>%
        dplyr::group_by(NAME = region_name, variable) %>%
        dplyr::summarise(value = sum(value))
    })
}

decennial_nhood <- function(table, year, .data, counties, state, sumfile, name, geoid, weight, key) {
  geoids <- unique(dplyr::pull(.data, {{ geoid }}))
  fetch <- decennial_tracts(table, year, geoids, counties, state, sumfile, key)

  .data %>%
    dplyr::left_join(fetch, by = stats::setNames("GEOID", rlang::as_label({{ rlang::enquo(geoid) }}))) %>%
    dplyr::group_by(variable, county, state, name) %>%
    dplyr::summarise(value = round(sum(value * {{ weight }}))) %>%
    dplyr::ungroup()
}
