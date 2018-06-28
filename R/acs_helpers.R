acs_towns <- function(table, year, towns, counties, state) {
  if (!is.null(counties) & ((length(counties) > 1) || (length(counties) == 1 & counties != "all"))) {
    fetch <- counties %>%
      purrr::map_dfr(function(county) {
        tidycensus::get_acs(geography = "county subdivision", table = table, year = year, state = state, county = county) %>%
          dplyr::mutate(county = county)
      }) %>%
      camiller::town_names(NAME)
  } else {
    fetch <- tidycensus::get_acs(geography = "county subdivision", table = table, year = year, state = state) %>%
      dplyr::mutate(state = state) %>%
      camiller::town_names(NAME)
  }

  if ((length(towns) > 1) || (length(towns) == 1 & towns != "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% towns)
  }
  fetch
}

acs_counties <- function(table, year, counties, state) {
  fetch <- tidycensus::get_acs(geography = "county", table = table, year = year, state = state) %>%
    dplyr::mutate(NAME = stringr::str_extract(NAME, "^.+County(?=, )"))
  if ((length(counties) > 1) || (length(counties) == 1 & counties != "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% counties | GEOID %in% counties)
  }
  fetch
}

acs_state <- function(table, year, state) {
  fetch <- tidycensus::get_acs(geography = "state", table = table, year = year) %>%
    dplyr::filter(NAME == state | GEOID == state)
  fetch
}

acs_regions <- function(table, year, regions, state) {
  fetch_towns <- tidycensus::get_acs(geography = "county subdivision", table = table, year = year, state = state) %>%
    camiller::town_names(NAME)

  regions %>%
    purrr::imap_dfr(function(region, region_name) {
      fetch_towns %>%
        dplyr::filter(NAME %in% region) %>%
        dplyr::group_by(NAME = region_name, variable) %>%
        dplyr::summarise(estimate = sum(estimate), moe = tidycensus::moe_sum(moe, estimate) %>% round())
    })
}

acs_neighborhoods <- function(table, year, neighborhoods, state) {
  fetch_tracts <- tidycensus::get_acs(geography = "tract", table = table, year = year, state = state)

  neighborhoods %>%
    purrr::imap_dfr(function(neighborhood, neighborhood_name) {
      fetch_tracts %>%
        dplyr::filter(GEOID %in% neighborhood) %>%
        dplyr::group_by(NAME = neighborhood_name, variable) %>%
        dplyr::summarise(estimate = sum(estimate), moe = tidycensus::moe_sum(moe, estimate) %>% round())
    })
}

