#' Fetch a decennial census table with multiple geography levels
#'
#' Fetch a data table from the decennial census via `tidycensus` with your choice of geographies at multiple levels. For geographies made of aggregates, i.e. neighborhoods made of tracts or regions made of towns, the returned table will have estimates summed and margins of error calculated for the whole area.
#'
#' This function essentially calls `tidycensus::get_decennial` multiple times, depending on geographic levels chosen, and does minor cleaning, filtering, and aggregation. Note that the underlying `tidycensus::get_decennial` requires a Census API key. As is the case with other `tidycensus` functions, `multi_geo_decennial` assumes this key is stored as `CENSUS_API_KEY` in your `.Renviron`. See [tidycensus::census_api_key()] for installation.
#'
#' @param table A string giving the decennial census table number.
#' @param year The year of the census table; currently defaults 2010 (most recent decennial census).
#' @param neighborhoods A named list of neighborhoods with their 11-digit tract GEOIDs (defaults `NULL`).
#' @param towns A character vector of towns to include; `"all"` (default) for all towns optionally filtered by county; or `NULL` to not fetch town-level table.
#' @param regions A named list of regions with their town names (defaults `NULL`).
#' @param counties A character vector of counties to include; `"all"` (default) for all counties in the state; or `NULL` to not fetch county-level table.
#' @param state A string: either name or two-digit FIPS code of a US state. Required; defaults `"09"` (Connecticut).
#' @param sumfile A string giving the summary file to pull from. Defaults `"sf1"`; in some rare cases, `"sf3"` may be appropriate.
#' @param verbose Logical: whether to print summary of geographies included. Defaults `TRUE`.
#' @return A tibble with GEOID, name, variable code, estimate, moe, geography level, and county, as applicable, for the chosen table.
#' @seealso [tidycensus::census_api_key()], [tidycensus::get_decennial()]
#' @examples
#' \dontrun{
#' multi_geo_decennial("P001", 2016,
#'   neighborhoods = list(downtown = c("09009140100", "09009361401", "09009361402"),
#'     dixwell = "090091416"),
#'   towns = "all",
#'   regions = list(inner_ring = c("Hamden", "East Haven", "West Haven")),
#'   counties = "New Haven County")
#' }
#' @export
multi_geo_decennial <- function(table, year = 2010, neighborhoods = NULL, towns = "all", regions = NULL, counties = "all", state = "09", sumfile = "sf1", verbose = TRUE) {
  st <- state
  # state must not be null
  assertthat::assert_that(!is.null(st), msg = "Must supply a state name or FIPS code")

  # decennial table numbers are a pain
  # compare table to decennial_nums
  if (table != "H0001" & !table %in% decennial_nums) {
    matches <- stringr::str_match(table, "^(HCT|H|PCT|PCO|P)(\\d{1,3}[A-Z]?)")
    type <- matches[, 2]
    nmbrs <- stringr::str_extract(matches[, 3], "\\d+") %>%
      stringr::str_pad(side = "left", width = 3, pad = "0")
    grp <- stringr::str_extract(matches[, 3], "\\D?$")

    stop(sprintf("Table %s doesn't seem valid. Did you mean %s?", table, paste0(type, nmbrs, grp)))
    # cat(sprintf("table %s is %s", table, paste0(type, nmbrs, grp)))

  }

  # state should be string; if numeric, pad it as FIPS code
  if (is.numeric(st)) {
    padded <- stringr::str_pad(st, width = 2, side = "left", pad = "0")
    message(sprintf("Converting state %s to %s", st, padded))
    st <- padded
  }

  # state must be in tidycensus::fips_codes as either fips code or name
  state_lookup <- tidycensus::fips_codes %>%
    dplyr::filter(state_code == st | state_name == st)
  assertthat::assert_that(nrow(state_lookup) > 0, msg = sprintf("%s is not a valid state name or FIPS code", st))

  # paste on County if counties don't end in it
  # drop counties that aren't in state_lookup with a warning
  # skip all this if counties == NULL or counties == "all"
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

  # printout geos
  if (verbose) {
    concept <- decennial_vars %>%
      dplyr::filter(stringr::str_detect(name, paste0("^", table))) %>%
      dplyr::pull(concept) %>%
      `[`(1)
    message("Table: ", concept)
    msg <- geo_printout(neighborhoods, towns, regions, counties, st, msa = F, new_england = F)
    message("Geographies included:\n", msg)
  }

  # fetch everything
  fetch <- list()

  if (!is.null(neighborhoods)) {
    fetch$neighborhoods <- decennial_neighborhoods(table, year, neighborhoods, st, sumfile)
  }
  if (!is.null(towns)) {
    fetch$towns <- decennial_towns(table, year, towns, counties, st, sumfile)
  }
  if (!is.null(regions)) {
    fetch$regions <- decennial_regions(table, year, regions, st, sumfile)
  }
  if (!is.null(counties)) {
    fetch$counties <- decennial_counties(table, year, counties, st, sumfile)
  }

  fetch$state <- decennial_state(table, year, st, sumfile)

  # take names of all items in fetch, reverse order, make level labels & bind all
  lvls <- fetch %>% rev()
  list(lvls, names(lvls), 1:length(lvls)) %>%
    purrr::pmap_dfr(function(df, lvl, i) {
      df %>% dplyr::mutate(level = paste(i, lvl, sep = "_"))
    })
}
