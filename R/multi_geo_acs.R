#' Fetch an ACS table with multiple geography levels
#'
#' Fetch a data table from the ACS via `tidycensus` with your choice of geographies at multiple levels. For geographies made of aggregates, i.e. neighborhoods made of tracts or regions made of towns, the returned table will have estimates summed and margins of error calculated for the whole area.
#'
#' This function essentially calls `tidycensus::get_acs()` multiple times, depending on geographic levels chosen, and does minor cleaning, filtering, and aggregation. Note that the underlying `tidycensus::get_acs()` requires a Census API key. As is the case with other `tidycensus` functions, `multi_geo_acs` assumes this key is stored as `CENSUS_API_KEY` in your `.Renviron`. See [tidycensus::census_api_key()] for installation.
#'
#' @param table A string giving the ACS table number.
#' @param year The year of the ACS table; currently defaults 2016 (most recent available).
#' @param towns A character vector of names of towns to include; `"all"` (default) for all towns optionally filtered by county; or `NULL` to not fetch town-level table.
#' @param regions A named list of regions with their town names (defaults `NULL`).
#' @param counties A character vector of names of counties to include; `"all"` (default) for all counties in the state; or `NULL` to not fetch county-level table.
#' @param state A string: either name or two-digit FIPS code of a US state. Required; defaults `"09"` (Connecticut).
#' @param tracts A character vector of 11-digit FIPS codes of tracts to include, or `"all"` for all tracts optionally filtered by county. Defaults `NULL`.
#' @param blockgroups A character vector of 12-digit FIPS codes of block groups to include, or `"all"` for all block groups optionally filtered by county. Defaults `NULL`.
#' @param msa Logical: whether to fetch New England states' metropolitan statistical areas. Defaults `FALSE`.
#' @param us Logical: whether to fetch US-level table. Defaults `FALSE`.
#' @param new_england Logical: if `TRUE` (the default), limits metro areas to just New England states.
#' @param survey A string: which ACS estimate to use. Defaults to 5-year (`"acs5"`), but can also be 1-year (`"acs1"`) or 3-year (`"acs3"`), though both 1-year and 3-year have limited availability.
#' @param verbose Logical: whether to print summary of geographies included. Defaults `TRUE`.
#' @param neighborhoods Temporarily deprecated: A named list of neighborhoods with their 11-digit tract GEOIDs (defaults NULL).
#' @return A tibble with GEOID, name, variable code, estimate, moe, geography level, state, and year, as applicable, for the chosen ACS table.
#' @seealso [tidycensus::census_api_key()], [tidycensus::get_acs()]
#' @examples
#' \dontrun{
#' multi_geo_acs("B01003", 2016,
#'   towns = "all",
#'   regions = list(inner_ring = c("Hamden", "East Haven", "West Haven")),
#'   counties = "New Haven County",
#'   tracts = unique(nhv_tracts$geoid))
#' }
#' @export
multi_geo_acs <- function(table, year = 2016, neighborhoods = NULL, towns = "all", regions = NULL, counties = "all", state = "09", tracts = NULL, blockgroups = NULL, msa = FALSE, us = FALSE, new_england = TRUE, survey = "acs5",  verbose = TRUE) {
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
    message(stringr::str_glue("Table {table}: {concept}"))
    msg <- geo_printout(neighborhoods, towns, regions, counties, st, msa, us, new_england)
    message("Geographies included:\n", msg)
  }

  # fetch everything using functions from acs_helpers
  fetch <- list()

  # if (!is.null(neighborhoods)) {
  #   # check nchar in the first FIPS code: block groups are 12 digits, tracts are 11
  #   fips_nchar <- nchar(unlist(neighborhoods)[1])
  #   if (blockgroups & fips_nchar != 12) {
  #     warning(stringr::str_glue("FIPS codes for block groups should have 12 digits, not {fips_nchar}. Neighborhoods may be dropped."))
  #   }
  #   if (!blockgroups & fips_nchar == 12) {
  #     warning(stringr::str_glue("FIPS codes for tracts should have 11 digits, not {fips_nchar}. Neighborhoods may be dropped."))
  #   }
  #   fetch$neighborhoods <- acs_neighborhoods(table, year, neighborhoods, st, blockgroups, survey)
  # }
  if (!is.null(blockgroups)) {
    fips_nchar <- nchar(blockgroups[1])
    if (!identical(blockgroups, "all") & fips_nchar != 11) {
      warning(stringr::str_glue("FIPS codes for block groups should have 11 digits, not {fips_nchar}. Block groups will likely be dropped."))
    }
    fetch$blockgroups <- acs_blockgroups(table, year, blockgroups, counties, state, survey)
  }
  if (!is.null(tracts)) {
    fips_nchar <- nchar(tracts[1])
    if (!identical(tracts, "all") & fips_nchar != 11) {
      warning(stringr::str_glue("FIPS codes for tracts should have 11 digits, not {fips_nchar}. Tracts will likely be dropped."))
    }
    fetch$tracts <- acs_tracts(table, year, tracts, counties, state, survey)
  }
  if (!is.null(towns)) {
    fetch$towns <- acs_towns(table, year, towns, counties, st, survey)
  }
  if (!is.null(regions)) {
    fetch$regions <- acs_regions(table, year, regions, st, survey)
  }
  if (!is.null(counties)) {
    fetch$counties <- acs_counties(table, year, counties, st, survey)
  }

  fetch$state <- acs_state(table, year, st, survey)

  if (msa) {
    if (year < 2015) warning("Heads up: OMB changed MSA boundaries around 2015. These might not match the ones you're expecting.")
    fetch$msa <- acs_msa(table, year, new_england, survey)
  }

  if (us) {
    fetch$us <- suppressMessages(tidycensus::get_acs(geography = "us", table = table, year = year, survey = survey))
  }

  # take the names of non-null items in fetch, reverse the order (i.e. largest geo to smallest),
  # then make level labels and bind all rows
  lvls <- fetch %>% rev()
  list(lvls, names(lvls), 1:length(lvls)) %>%
    purrr::pmap_dfr(function(df, lvl, i) {
      df %>% dplyr::mutate(level = paste(i, lvl, sep = "_"))
    }) %>%
    dplyr::mutate(year = year) %>%
    dplyr::mutate(level = forcats::as_factor(level))
}
