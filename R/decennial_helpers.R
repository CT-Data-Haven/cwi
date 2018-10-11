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

decennial_towns <- function(table, year, towns, counties, state, sumfile) {
  st <- state

  fetch <- counties_to_fetch(st = st, counties = counties) %>%
    purrr::map_dfr(function(county) {
      suppressMessages(tidycensus::get_decennial(geography = "county subdivision", table = table, year = year, state = st, county = county, sumfile = sumfile)) %>%
        dplyr::mutate(county = county)
    }) %>%
    camiller::town_names(NAME)

  if (!identical(towns, "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% towns)
  }
  fetch %>%
    dplyr::mutate(state = st)
}

decennial_counties <- function(table, year, counties, state, sumfile) {
  fetch <- suppressMessages(tidycensus::get_decennial(geography = "county", table = table, year = year, state = state, sumfile = sumfile)) %>%
    dplyr::mutate(NAME = stringr::str_extract(NAME, "^.+County")) %>%
    dplyr::mutate(state = state)

  if (!identical(counties, "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% counties | GEOID %in% counties)
  }
  fetch
}

decennial_state <- function(table, year, state, sumfile) {
  fetch <- suppressMessages(tidycensus::get_decennial(geography = "state", table = table, year = year, sumfile = sumfile)) %>%
    dplyr::filter(NAME == state | GEOID == state)
  fetch
}

decennial_regions <- function(table, year, regions, state, sumfile) {
  fetch_towns <- decennial_towns(table, year, towns = "all", counties = "all", state, sumfile)

  regions %>%
    purrr::imap_dfr(function(region, region_name) {
      fetch_towns %>%
        dplyr::filter(NAME %in% region) %>%
        dplyr::group_by(NAME = region_name, variable) %>%
        dplyr::summarise(value = sum(value))
    })
}

decennial_neighborhoods <- function(table, year, neighborhoods, state, sumfile) {
  fetch_tracts <- suppressMessages(tidycensus::get_decennial(geography = "tract", table = table, year = year, state = state))

  neighborhoods %>%
    purrr::imap_dfr(function(neighborhood, neighborhood_name) {
      fetch_tracts %>%
        dplyr::filter(GEOID %in% neighborhood) %>%
        dplyr::group_by(NAME = neighborhood_name, variable) %>%
        dplyr::summarise(value = sum(value))
    })
}
