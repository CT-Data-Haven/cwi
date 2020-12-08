acs_towns <- function(table, year, towns, counties, state, survey, key) {
  fetch <- counties_to_fetch(st = state, counties = counties) %>%
    purrr::map_dfr(function(county) {
      suppressMessages(tidycensus::get_acs(geography = "county subdivision", table = table, year = year, state = state, county = county, survey = survey, key = key)) %>%
        dplyr::mutate(county = county)
    }) %>%
    town_names(NAME)

  if (!identical(towns, "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% towns)
  }
  fetch %>%
    dplyr::mutate(state = state)
}

acs_counties <- function(table, year, counties, state, survey, key) {
  fetch <- suppressMessages(tidycensus::get_acs(geography = "county", table = table, year = year, state = state, survey = survey, key = key)) %>%
    dplyr::mutate(NAME = stringr::str_extract(NAME, "^.+County(?=, )")) %>%
    dplyr::mutate(state = state)

  if (!identical(counties, "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% counties | GEOID %in% counties)
  }
  fetch
}

acs_tracts <- function(table, year, tracts, counties, state, survey, key) {
  fetch <- counties_to_fetch(st = state, counties = counties) %>%
    purrr::map_dfr(function(county) {
      suppressMessages(tidycensus::get_acs(geography = "tract", table = table, year = year, state = state, county = county, survey = survey, key = key)) %>%
        dplyr::mutate(county = county)
    })

  if (!identical(tracts, "all")) {
    fetch <- fetch %>% dplyr::filter(GEOID %in% tracts)
  }
  fetch %>%
    dplyr::mutate(state = state)
}

acs_blockgroups <- function(table, year, blockgroups, counties, state, survey, key) {
  fetch <- counties_to_fetch(st = state, counties = counties) %>%
    purrr::map_dfr(function(county) {
      suppressMessages(tidycensus::get_acs(geography = "block group", table = table, year = year, state = state, county = county, survey = survey, key = key)) %>%
        dplyr::mutate(county = county)
    })

  if (!identical(blockgroups, "all")) {
    fetch <- fetch %>% dplyr::filter(GEOID %in% blockgroups)
  }
  fetch %>%
    dplyr::mutate(state = state)
}

acs_state <- function(table, year, state, survey, key) {
  fetch <- suppressMessages(tidycensus::get_acs(geography = "state", table = table, year = year, survey = survey, key = key)) %>%
    dplyr::filter(NAME == state | GEOID == state)
  fetch
}

acs_regions <- function(table, year, regions, state, survey, key) {
  fetch_towns <- acs_towns(table, year, "all", NULL, state, survey, key = key)

  regions %>%
    purrr::imap_dfr(function(region, region_name) {
      fetch_towns %>%
        dplyr::filter(NAME %in% region) %>%
        dplyr::group_by(NAME = region_name, variable) %>%
        dplyr::summarise(estimate = sum(estimate),
                         moe = round(tidycensus::moe_sum(moe, estimate)))
    })
}

acs_nhood <- function(table, year, .data, counties, state, survey, name, geoid, weight, key, is_tract) {
  geoids <- unique(dplyr::pull(.data, {{ geoid }}))
  if (is_tract) {
    fetch <- acs_tracts(table, year, geoids, counties, state, survey, key)
  } else {
    fetch <- acs_blockgroups(table, year, geoids, counties, state, survey, key)
  }

  .data %>%
    dplyr::left_join(fetch, by = stats::setNames("GEOID", rlang::as_label({{ rlang::enquo(geoid) }}))) %>%
    dplyr::group_by(variable, county, state, name) %>%
    dplyr::summarise(estimate = round(sum(estimate * {{ weight }})),
                     moe = round(tidycensus::moe_sum(moe, estimate * {{ weight }}))) %>%
    dplyr::ungroup()
}

acs_msa <- function(table, year, new_england, survey, key) {
  fetch <- suppressMessages(tidycensus::get_acs(geography = "metropolitan statistical area/micropolitan statistical area", table = table, year = year, survey = survey, key = key))
  if (new_england) {
    ne_geoid <- msa %>%
      dplyr::filter(region == "New England") %>%
      dplyr::pull(GEOID)
    fetch <- fetch %>%
      dplyr::filter(GEOID %in% ne_geoid)
  }

  fetch
}
