acs_towns <- function(table, year, towns, counties, state, survey) {
  fetch <- counties_to_fetch(st = state, counties = counties) %>%
    purrr::map_dfr(function(county) {
      suppressMessages(tidycensus::get_acs(geography = "county subdivision", table = table, year = year, state = state, county = county, survey = survey)) %>%
        dplyr::mutate(county = county)
    }) %>%
    town_names(NAME)

  if (!identical(towns, "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% towns)
  }
  fetch %>%
    dplyr::mutate(state = state)
}

acs_counties <- function(table, year, counties, state, survey) {
  fetch <- suppressMessages(tidycensus::get_acs(geography = "county", table = table, year = year, state = state, survey = survey)) %>%
    dplyr::mutate(NAME = stringr::str_extract(NAME, "^.+County(?=, )")) %>%
    dplyr::mutate(state = state)

  if (!identical(counties, "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% counties | GEOID %in% counties)
  }
  fetch
}

acs_tracts <- function(table, year, tracts, counties, state, survey) {
  fetch <- counties_to_fetch(st = state, counties = counties) %>%
    purrr::map_dfr(function(county) {
      suppressMessages(tidycensus::get_acs(geography = "tract", table = table, year = year, state = state, county = county, survey = survey)) %>%
        dplyr::mutate(county = county)
    })

  if (!identical(tracts, "all")) {
    fetch <- fetch %>% dplyr::filter(GEOID %in% tracts)
  }
  fetch %>%
    dplyr::mutate(state = state)
}

acs_blockgroups <- function(table, year, blockgroups, counties, state, survey) {
  fetch <- counties_to_fetch(st = state, counties = counties) %>%
    purrr::map_dfr(function(county) {
      suppressMessages(tidycensus::get_acs(geography = "block group", table = table, year = year, state = state, county = county, survey = survey)) %>%
        dplyr::mutate(county = county)
    })

  if (!identical(blockgroups, "all")) {
    fetch <- fetch %>% dplyr::filter(GEOID %in% blockgroups)
  }
  fetch %>%
    dplyr::mutate(state = state)
}

acs_state <- function(table, year, state, survey) {
  fetch <- suppressMessages(tidycensus::get_acs(geography = "state", table = table, year = year, survey = survey)) %>%
    dplyr::filter(NAME == state | GEOID == state)
  fetch
}

acs_regions <- function(table, year, regions, state, survey) {
  fetch_towns <- acs_towns(table, year, "all", NULL, state, survey)

  regions %>%
    purrr::imap_dfr(function(region, region_name) {
      fetch_towns %>%
        dplyr::filter(NAME %in% region) %>%
        dplyr::group_by(NAME = region_name, variable) %>%
        dplyr::summarise(estimate = sum(estimate), moe = tidycensus::moe_sum(moe, estimate) %>% round())
    })
}

acs_neighborhoods <- function(table, year, neighborhoods, state, blockgroups, survey) {
  if (blockgroups) {
    fetch_nhoods <- suppressMessages(tidycensus::get_acs(geography = "block group", table = table, year = year, state = state, survey = survey))
  } else {
    fetch_nhoods <- suppressMessages(tidycensus::get_acs(geography = "tract", table = table, year = year, state = state, survey = survey))
  }

  # TODO: need to handle weighting
  neighborhoods %>%
    purrr::imap_dfr(function(neighborhood, neighborhood_name) {
      fetch_nhoods %>%
        dplyr::filter(GEOID %in% neighborhood) %>%
        dplyr::group_by(NAME = neighborhood_name, variable) %>%
        dplyr::summarise(estimate = sum(estimate), moe = tidycensus::moe_sum(moe, estimate) %>% round())
    })
}

acs_msa <- function(table, year, new_england, survey) {
  fetch <- suppressMessages(tidycensus::get_acs(geography = "metropolitan statistical area/micropolitan statistical area", table = table, year = year, survey = survey))
  if (new_england) {
    ne_geoid <- msa %>%
      dplyr::filter(region == "New England") %>%
      dplyr::pull(GEOID)
    fetch <- fetch %>%
      dplyr::filter(GEOID %in% ne_geoid)
  }

  fetch
}
