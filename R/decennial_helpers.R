decennial_towns <- function(table, year, towns, counties, state, sumfile) {
  if (!is.null(counties) & !identical(counties, "all")) {
    fetch <- counties %>%
      purrr::map_dfr(function(county) {
        suppressMessages(tidycensus::get_decennial(geography = "county subdivision", table = table, year = year, state = state, county = county, sumfile = sumfile)) %>%
          dplyr::mutate(county = county)
      }) %>%
      camiller::town_names(NAME)
  } else {
    fetch <- suppressMessages(tidycensus::get_decennial(geography = "county subdivision", table = table, year = year, state = state, sumfile = sumfile)) %>%
      dplyr::mutate(state = state) %>%
      camiller::town_names(NAME)
  }

  if (!identical(towns, "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% towns)
  }
  fetch %>%
    dplyr::mutate(state = state)
}

decennial_counties <- function(table, year, counties, state, sumfile) {
  fetch <- suppressMessages(tidycensus::get_decennial(geography = "county", table = table, year = year, state = state, sumfile = sumfile)) %>%
    dplyr::mutate(NAME = stringr::str_extract(NAME, "^.+County(?=, )")) %>%
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
  fetch_towns <- suppressMessages(tidycensus::get_decennial(geography = "county subdivision", table = table, year = year, state = state, sumfile = sumfile)) %>%
    camiller::town_names(NAME)

  regions %>%
    purrr::imap_dfr(function(region, region_name) {
      fetch_towns %>%
        dplyr::filter(NAME %in% region) %>%
        dplyr::group_by(NAME = region_name, variable) %>%
        dplyr::summarise(estimate = sum(estimate), moe = tidycensus::moe_sum(moe, estimate) %>% round())
    })
}

decennial_neighborhoods <- function(table, year, neighborhoods, state, sumfile) {
  fetch_tracts <- suppressMessages(tidycensus::get_decennial(geography = "tract", table = table, year = year, state = state))

  neighborhoods %>%
    purrr::imap_dfr(function(neighborhood, neighborhood_name) {
      fetch_tracts %>%
        dplyr::filter(GEOID %in% neighborhood) %>%
        dplyr::group_by(NAME = neighborhood_name, variable) %>%
        dplyr::summarise(estimate = sum(estimate), moe = tidycensus::moe_sum(moe, estimate) %>% round())
    })
}
