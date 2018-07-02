#' Fetch an ACS table with multiple geography levels
#'
#' Fetch a data table from the ACS via `tidycensus` with your choice of geographies at multiple levels. For geographies made of aggregates, i.e. neighborhoods made of tracts or regions made of towns, the returned table will have estimates summed and margins of error calculated for the whole area.
#'
#' This function essentially calls `tidycensus::get_acs` multiple times, depending on geographic levels chosen, and does minor cleaning, filtering, and aggregation. Note that the underlying `tidycensus::get_acs` requires a Census API key. As is the case with other `tidycensus` functions, `multi_geo_acs` assumes this key is stored as `CENSUS_API_KEY` in your `.Renviron`. See [tidycensus::census_api_key()] for installation.
#'
#' @param table A string giving the ACS table number.
#' @param year The year of the ACS table; currently defaults 2016 (most recent available).
#' @param neighborhoods A named list of neighborhoods with their 11-digit tract GEOIDs (defaults `NULL`).
#' @param towns A character vector of towns to include; `"all"` (default) for all towns optionally filtered by county; or `NULL` to not fetch town-level table.
#' @param regions A named list of regions with their town names (defaults `NULL`).
#' @param counties A character vector of counties to include; `"all"` (default) for all counties in the state; or `NULL` to not fetch county-level table.
#' @param state A string: either name or two-digit FIPS code of a US state. Required; defaults `"09"` (Connecticut).
#' @param msa Logical: whether to fetch New England states' metropolitan statistical areas. Defaults `FALSE`.
#' @param us Logical: whether to fetch US-level table. Defaults `FALSE`.
#' @return A tibble with GEOID, name, variable code, estimate, moe, geography level, and county, as applicable, for the chosen ACS table.
#' @seealso [tidycensus::census_api_key()], [tidycensus::get_acs()]
#' @examples
#' \dontrun{
#' multi_geo_acs("B01003", 2016,
#'   neighborhoods = list(downtown = c("09009140100", "09009361401", "09009361402"),
#'     dixwell = "090091416"),
#'   towns = "all",
#'   regions = list(inner_ring = c("Hamden", "East Haven", "West Haven")),
#'   counties = "New Haven County")
#' }
#' @export
multi_geo_acs <- function(table, year = 2016, neighborhoods = NULL, towns = "all", regions = NULL, counties = "all", state = "09", msa = FALSE, us = FALSE) {
  if (is.null(state)) stop("Must supply a state name or FIPS code")

  # if counties don't already end in County, paste it on
  if (!is.null(counties) & !identical(counties, "all")) {
    counties <- stringr::str_replace(counties, "(?<! County)$", " County")
  }

  # make message printing out current geographies
  msg <- geo_printout(neighborhoods, towns, regions, counties, state, msa, us)
  message("Geographies included:\n", msg)

  fetch <- list()

  if (!is.null(neighborhoods)) {
    fetch$neighborhoods <- acs_neighborhoods(table, year, neighborhoods, state)
  }
  if (!is.null(towns)) {
    fetch$towns <- acs_towns(table, year, towns, counties, state)
  }
  if (!is.null(regions)) {
    fetch$regions <- acs_regions(table, year, regions, state)
  }
  if (!is.null(counties)) {
    fetch$counties <- acs_counties(table, year, counties, state)
  }

  fetch$state <- acs_state(table, year, state)

  if (msa) {
    fetch$msa <- acs_msa(table, year)
  }

  if (us) {
    fetch$us <- tidycensus::get_acs(geography = "us", table = table, year = year)
  }

  # take the names of non-null items in fetch, reverse the order (i.e. largest geo to smallest),
  # then make level labels and bind all rows
  lvls <- fetch %>% rev()
  list(lvls, names(lvls), 1:length(lvls)) %>%
    purrr::pmap_dfr(function(df, lvl, i) {
      df %>% dplyr::mutate(level = paste(i, lvl, sep = "_"))
    })
}
