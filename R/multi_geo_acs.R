#' Fetch an ACS table with multiple geography levels
#'
#' Fetch a data table from the ACS via `tidycensus` with your choice of geographies at multiple levels. For geographies made of aggregates, i.e. neighborhoods made of tracts or regions made of towns, the returned table will have estimates summed and margins of error calculated for the whole area.
#'
#' This function essentially calls `tidycensus::get_acs()` multiple times, depending on geographic levels chosen, and does minor cleaning, filtering, and aggregation. Note that the underlying `tidycensus::get_acs()` requires a Census API key. As is the case with other `tidycensus` functions, `multi_geo_acs` assumes this key is stored as `CENSUS_API_KEY` in your `.Renviron`. See [tidycensus::census_api_key()] for installation.
#'
#' @param table A string giving the ACS table number.
#' @param year The year of the ACS table; currently defaults 2019 (most recent available).
#' @param towns A character vector of names of towns to include; `"all"` (default) for all towns optionally filtered by county; or `NULL` to not fetch town-level table.
#' @param regions A named list of regions with their town names (defaults `NULL`).
#' @param counties A character vector of names of counties to include; `"all"` (default) for all counties in the state; or `NULL` to not fetch county-level table.
#' @param state A string: either name or two-digit FIPS code of a US state. Required; defaults `"09"` (Connecticut).
#' @param tracts A character vector of 11-digit FIPS codes of tracts to include, or `"all"` for all tracts optionally filtered by county. Defaults `NULL`.
#' @param blockgroups A character vector of 12-digit FIPS codes of block groups to include, or `"all"` for all block groups optionally filtered by county. Defaults `NULL`.
#' @param msa Logical: whether to fetch New England states' metropolitan statistical areas. Defaults `FALSE`.
#' @param us Logical: whether to fetch US-level table. Defaults `FALSE`.
#' @param new_england Logical: if `TRUE` (the default), limits metro areas to just New England states.
#' @param survey A string: which ACS estimate to use. Defaults to 5-year (`"acs5"`), but can also be 1-year (`"acs1"`).
#' @param neighborhoods A data frame with columns for neighborhood name, GEOID of either tracts or block groups, and weight, e.g. share of each tract assigned to a neighborhood. If included, weighted sums and MOEs will be returned for neighborhoods. Try to match the formatting of the [built-in neighborhood tables][neighborhood_tracts].
#' @param name Bare column name of neighborhood names. Only relevant if a neighborhood weight table is being used. Defaults `name` to match the neighborhood lookup datasets.
#' @param geoid Bare column name of neighborhood GEOIDs, either tracts or block groups. Only relevant if a neighborhood weight table is being used. Defaults `geoid` to match the neighborhood lookup datasets.
#' @param weight Bare column name of weights between neighborhood names and tract/block groups. Only relevant if a neighborhood weight table is being used. Defaults `weight` to match the neighborhood lookup datasets.
#' @param verbose Logical: whether to print summary of geographies included. Defaults `TRUE`.
#' @param key String: Census API key. If `NULL` (default), takes the value from `Sys.getenv("CENSUS_API_KEY")`.
#' @return A tibble with GEOID, name, variable code, estimate, moe, geography level, state, and year, as applicable, for the chosen ACS table.
#' @seealso [tidycensus::census_api_key()], [tidycensus::get_acs()]
#' @examples
#' \dontrun{
#' multi_geo_acs("B01003", 2019,
#'   towns = "all",
#'   regions = list(inner_ring = c("Hamden", "East Haven", "West Haven")),
#'   counties = "New Haven County",
#'   tracts = unique(new_haven_tracts$geoid))
#'
#' multi_geo_acs("B01003", 2018,
#'   towns = "Bridgeport",
#'   counties = "Fairfield County",
#'   neighborhoods = bridgeport_tracts
#' )
#'
#' }
#' @export
multi_geo_acs <- function(table, year = 2019, towns = "all", regions = NULL, counties = "all", state = "09", neighborhoods = NULL, tracts = NULL, blockgroups = NULL, msa = FALSE, us = FALSE, new_england = TRUE, name = name, geoid = geoid, weight = weight, survey = c("acs5", "acs1"), verbose = TRUE, key = NULL) {
  # check key
  if (is.null(key)) {
    key <- Sys.getenv("CENSUS_API_KEY")
  }
  survey <- match.arg(survey, c("acs5", "acs1"))
  if (nchar(key) == 0) stop("Must supply an API key. See the docs on where to store it.")
  st <- state
  # state must not be null
  if (is.null(st)) stop("Must supply a state name or FIPS code")

  # state should be string; if it's numeric, make sure it's padded as FIPS code
  if (is.numeric(st)) {
    padded <- stringr::str_pad(st, width = 2, side = "left", pad = "0")
    message(sprintf("Converting state %s to %s", st, padded))
    st <- padded
  }

  # state must be in tidycensus::fips_codes somewhere
  state_lookup <- tidycensus::fips_codes %>%
    dplyr::filter(state_code == st | state_name == st)
  assertthat::assert_that(nrow(state_lookup) > 0, msg = sprintf("%s is not a valid state name or FIPS code", st))

  # if counties don't already end in County, paste it on
  # drop counties that aren't in state lookup with a warning, only if counties != all
  if (!is.null(counties) & !identical(counties, "all")) {
    counties <- stringr::str_replace(counties, "(?<! County)$", " County")

    possible_counties <- state_lookup %>%
      dplyr::pull(county)
    if (length(setdiff(counties, possible_counties))) {
      purrr::walk(setdiff(counties, possible_counties), function(county) {
        warning(sprintf("%s is not a valid county name and is being dropped", county))
      })
    }
    counties <- intersect(counties, possible_counties)
  }

  # handle situations where table doesn't exist that year/survey
  # avail has table number and concept also
  avail <- acs_available(table, year, survey)
  assertthat::assert_that(avail[["is_avail"]], msg = stringr::str_glue("Table {table} for {year} {survey} is not available in the API."))

  # make message printing out current geographies
  if (verbose) {
    acs_vars <- clean_acs_vars(year = year, survey = survey)
    concept <- acs_vars %>%
      dplyr::filter(stringr::str_detect(name, paste0("^", table))) %>%
      dplyr::pull(concept) %>%
      `[`(1)
    message(stringr::str_glue("Table {table}: {concept}, {year}"))
    if (!is.null(neighborhoods)) {
      msg <- geo_printout(dplyr::pull(neighborhoods, {{ name }}), towns, regions, counties, st, msa, us, new_england)
    } else {
      msg <- geo_printout(neighborhoods, towns, regions, counties, st, msa, us, new_england)
    }
    message("Geographies included:\n", msg)
  }

  # fetch everything using functions from acs_helpers
  fetch <- list()


  if (!is.null(blockgroups)) {
    fips_nchar <- nchar(blockgroups)
    if (!identical(blockgroups, "all") & !all(fips_nchar == 12)) {
      warning(stringr::str_glue("FIPS codes for block groups should have 12 digits, not {fips_nchar[1]}. Block groups will likely be dropped."))
    }
    fetch[["blockgroups"]] <- acs_blockgroups(table, year, blockgroups, counties, st, survey, key)
  }
  if (!is.null(tracts)) {
    fips_nchar <- nchar(tracts)
    if (!identical(tracts, "all") & !all(fips_nchar == 11)) {
      warning(stringr::str_glue("FIPS codes for tracts should have 11 digits, not {fips_nchar[1]}. Tracts will likely be dropped."))
    }
    fetch[["tracts"]] <- acs_tracts(table, year, tracts, counties, st, survey, key)
  }

  if (!is.null(neighborhoods)) {
    fips_nchar <- nchar(dplyr::pull(neighborhoods, {{ geoid }}))
    if (all(fips_nchar == 11)) {
      message("Assuming neighborhood GEOIDs are for tracts")
      fetch[["neighborhoods"]] <- acs_nhood(table, year, neighborhoods, counties, state, survey, name, geoid, weight, key, is_tract = TRUE)
    } else if (all(fips_nchar == 12)) {
      message("Assuming neighborhood GEOIDs are for block groups")
      fetch[["neighborhoods"]] <- acs_nhood(table, year, neighborhoods, counties, state, survey, name, geoid, weight, key, is_tract = FALSE)
    } else {
      message("The GEOIDs to create neighborhoods seem to be incorrect, so neighborhoods are being skipped. Check that they are either tracts or block groups.")
    }
  }

  if (!is.null(towns)) {
    fetch[["towns"]] <- acs_towns(table, year, towns, counties, st, survey, key)
  }
  if (!is.null(regions)) {
    fetch[["regions"]] <- acs_regions(table, year, regions, st, survey, key)
  }
  if (!is.null(counties)) {
    fetch[["counties"]] <- acs_counties(table, year, counties, st, survey, key)
  }

  fetch[["state"]] <- acs_state(table, year, st, survey, key)

  if (msa) {
    if (year < 2015) warning("Heads up: OMB changed MSA boundaries around 2015. These might not match the ones you're expecting.")
    fetch[["msa"]] <- acs_msa(table, year, new_england, survey, key)
  }

  if (us) {
    fetch[["us"]] <- suppressMessages(tidycensus::get_acs(geography = "us", table = table, year = year, survey = survey, key = key))
  }

  # take the names of non-null items in fetch, reverse the order (i.e. largest geo to smallest),
  # then make level labels and bind all rows
  lvls <- rev(fetch)
  list(lvls, names(lvls), 1:length(lvls)) %>%
    purrr::pmap_dfr(function(df, lvl, i) {
      df %>%
        dplyr::mutate(level = paste(i, lvl, sep = "_")) %>%
        janitor::clean_names()
    }) %>%
    dplyr::mutate(year = year) %>%
    dplyr::mutate(level = forcats::as_factor(level))
}
