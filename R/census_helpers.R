## UTILS ----
wrap_census <- function(src, geography, table, year, state, dataset, key, ...) {
  if (src == "acs") {
    suppressMessages(httr::with_config(httr::user_agent("cwi"), tidycensus::get_acs(geography = geography, table = table, year = year, state = state, survey = dataset, key = key, cache_table = TRUE, ...)))
  } else if (src == "decennial") {
    suppressMessages(httr::with_config(httr::user_agent("cwi"), tidycensus::get_decennial(geography = geography, table = table, year = year, state = state, sumfile = dataset, key = key, cache_table = TRUE, ...)))
  } else {
    return(NULL)
  }
}



## TOWNS ----
# fetch all in the state, then filter by county or arg
census_towns <- function(src, table, year, towns, counties, state, dataset, key, sleep, ...) {
  # tidycensus now handles skipped levels in hierarchy i.e. can get towns w/o specifying counties
  Sys.sleep(sleep)

  xw <- county_x_state(state, counties)
  fetch <- wrap_census(src, geography = "county subdivision", table = table, year = year, state = state, dataset = dataset, key = key, ...)
  fetch <- town_names(fetch, NAME)
  fetch$county_geoid <- substr(fetch$GEOID, 1, 5)
  fetch <- dplyr::inner_join(fetch, xw, by = "county_geoid")

  if (!identical(towns, "all")) {
    fetch <- dplyr::filter(fetch, NAME %in% towns)
  }
  fetch$county_geoid <- NULL
  fetch
}

## COUNTIES ----
# fetch all, then filter by arg
census_counties <- function(src, table, year, counties, state, dataset, key, sleep, ...) {
  Sys.sleep(sleep)
  xw <- county_x_state(state, counties)

  fetch <- wrap_census(src, geography = "county", table = table, year = year, state = state, dataset = dataset, key = key, ...)
  fetch$NAME <- stringr::str_extract(fetch$NAME, "^[\\w\\s]+County(?=, )")

  fetch$county_geoid <- substr(fetch$GEOID, 1, 5)
  fetch <- dplyr::inner_join(fetch, xw, by = "county_geoid")
  fetch$county_geoid <- NULL
  fetch$county <- NULL
  fetch
}

## TRACTS ----
# fetch all in the state, then filter by county or arg
census_tracts <- function(src, table, year, tracts, counties, state, dataset, key, sleep, ...) {
  Sys.sleep(sleep)

  fetch <- wrap_census(src, geography = "tract", table = table, year = year, state = state, dataset = dataset, key = key, ...)

  if (identical(tracts, "all")) {
    xw <- county_x_state(state, counties)
  } else {
    xw <- county_x_state(state, "all")
    fetch <- dplyr::filter(fetch, GEOID %in% tracts)
  }
  fetch$county_geoid <- substr(fetch$GEOID, 1, 5)
  fetch <- dplyr::inner_join(fetch, xw, by = "county_geoid")
  fetch$county_geoid <- NULL
  fetch$NAME <- fetch$GEOID
  fetch
}

## BLOCKGROUPS ----
# fetch all in the state, then filter by county or arg
census_blockgroups <- function(src, table, year, blockgroups, counties, state, dataset, key, sleep, ...) {
  Sys.sleep(sleep)

  fetch <- wrap_census(src, geography = "block group", table = table, year = year, state = state, dataset = dataset, key = key, ...)

  if (identical(blockgroups, "all")) {
    xw <- county_x_state(state, counties)
  } else {
    xw <- county_x_state(state, "all")
    fetch <- dplyr::filter(fetch, GEOID %in% blockgroups)
  }
  fetch$county_geoid <- substr(fetch$GEOID, 1, 5)
  fetch <- dplyr::inner_join(fetch, xw, by = "county_geoid")
  fetch$county_geoid <- NULL
  fetch$NAME <- fetch$GEOID
  fetch
}

## STATE ----
# fetch all, then filter
census_state <- function(src, table, year, state, dataset, key, sleep, ...) {
  Sys.sleep(sleep)
  fetch <- wrap_census(src, geography = "state", table = table, year = year, state = NULL, dataset = dataset, key = key, ...)
  fetch <- dplyr::filter(fetch, GEOID == state)
  fetch
}

## REGIONS ----
# fetch all towns, then filter by region & aggregate
# needs name of estimate/value column
census_regions <- function(src, table, year, regions, state, value, dataset, key, sleep, ...) {
  Sys.sleep(sleep)
  region_df <- tibble::enframe(regions, value = "town")
  region_df <- tidyr::unnest(region_df, town)
  fetch <- census_towns(src, table, year, "all", "all", state, dataset, key, 0, ...)
  fetch <- dplyr::inner_join(fetch, region_df, by = c("NAME" = "town"))
  fetch <- dplyr::group_by(fetch, state, NAME = name, variable)
  if ("moe" %in% names(fetch)) {
    fetch <- dplyr::summarise(fetch,
                              dplyr::across({{ value }}, sum),
                              moe = round(tidycensus::moe_sum(moe, {{ value }})))
  } else {
    fetch <- dplyr::summarise(fetch,
                              dplyr::across({{ value }}, sum))
  }
  fetch <- dplyr::ungroup(fetch)
  fetch
}

## NEIGHBORHOODS ----
# fetch tracts or bgs, then filter by nhood table & aggregate
# let counties be independent of neighborhoods
# needs name of estimate/value column
census_nhood <- function(src, table, year, nhood_data, state, name, geoid, weight, is_tract, value, dataset, key, sleep, ...) {
  Sys.sleep(sleep)
  if (is_tract) {
    fetch <- census_tracts(src, table, year, "all", "all", state, dataset, key, 0, ...)
  } else {
    fetch <- census_blockgroups(src, table, year, "all", "all", state, dataset, key, 0, ...)
  }
  fetch <- dplyr::inner_join(nhood_data, fetch, by = stats::setNames("GEOID", rlang::as_label(rlang::enquo(geoid))))
  fetch <- dplyr::group_by(fetch, state, county, {{ name }}, variable)
  if ("moe" %in% names(fetch)) {
    fetch <- dplyr::summarise(fetch,
                              dplyr::across({{ value }}, function(x) round(sum({{ value }} * {{ weight }}))),
                              moe = round(tidycensus::moe_sum(moe, {{ value }} * {{ weight }})))
  } else {
    fetch <- dplyr::summarise(fetch,
                              dplyr::across({{ value }}, function(x) round(sum({{ value }} * {{ weight }}))))
  }
  fetch <- dplyr::ungroup(fetch)
  fetch
}

## MSAs ----
# fetch all in us, then filter
census_msa <- function(src, table, year, new_england, dataset, key, sleep, ...) {
  Sys.sleep(sleep)
  if (year < 2015) {
    cli::cli_inform("Note: OMB changed MSA boundaries around 2015. These might not match the ones you're expecting.")
  }
  # labeling for MSA changed with 2021
  if (year >= 2021) {
    geo <- "metropolitan/micropolitan statistical area"
  } else {
    geo <- "metropolitan statistical area/micropolitan statistical area"
  }
  fetch <- wrap_census(src, geography = geo, table = table, year = year, state = NULL, dataset = dataset, key = key, ...)
  if (new_england) {
    ne_msa <- dplyr::filter(cwi::msa, region == "New England")
    fetch <- dplyr::semi_join(fetch, ne_msa, by = c("GEOID" = "geoid"))
  }
  fetch
}

## PUMAs ----
# fetch all in state, then filter like tracts (only available for ACS)
census_pumas <- function(src, table, year, pumas, counties, state, dataset, key, sleep, ...) {
  Sys.sleep(sleep)

  fetch <- wrap_census(src, geography = "public use microdata area", table = table, year = year, state = state, dataset = dataset, key = key, ...)

  if (identical(pumas, "all")) {
    xw <- county_x_state(state, counties)
  } else {
    xw <- county_x_state(state, "all")
    fetch <- dplyr::filter(fetch, GEOID %in% pumas)
  }
  fetch$county_geoid <- substr(fetch$GEOID, 1, 5)
  fetch <- dplyr::inner_join(fetch, xw, by = "county_geoid")
  fetch$county_geoid <- NULL
  fetch$NAME <- fetch$GEOID
  fetch
}

## US ----
# fetch
census_us <- function(src, table, year, dataset, key, sleep, ...) {
  Sys.sleep(sleep)
  fetch <- wrap_census(src, geography = "us", table = table, year = year, state = NULL, dataset = dataset, key = key, ...)
  fetch
}
