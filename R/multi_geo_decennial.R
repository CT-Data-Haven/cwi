#' Fetch a decennial census table with multiple geography levels
#'
#' Fetch a data table from the decennial census via `tidycensus` with your choice of geographies at multiple levels. For geographies made of aggregates, i.e. neighborhoods made of tracts or regions made of towns, the returned table will have estimates summed and margins of error calculated for the whole area.
#'
#' This function essentially calls `tidycensus::get_decennial()` multiple times, depending on geographic levels chosen, and does minor cleaning, filtering, and aggregation. Note that the underlying `tidycensus::get_decennial()` requires a Census API key. As is the case with other `tidycensus` functions, `multi_geo_decennial` assumes this key is stored as `CENSUS_API_KEY` in your `.Renviron`. See [tidycensus::census_api_key()] for installation.
#'
#' Be advised that decennial table numbers may change from year to year, so if you're looking at trends, check FactFinder or another source to make sure the tables have the same meaning. Setting `verbose = TRUE` is helpful for this as well.
#'
#' @param table A string giving the decennial census table number. These are generally formatted as one or more letters, 3 numbers, and optionally a letter.
#' @param year The year of the census table; currently defaults 2010 (most recent decennial census).
#' @param towns A character vector of towns to include; `"all"` (default) for all towns optionally filtered by county; or `NULL` to not fetch town-level table.
#' @param regions A named list of regions with their town names (defaults `NULL`).
#' @param counties A character vector of counties to include; `"all"` (default) for all counties in the state; or `NULL` to not fetch county-level table.
#' @param state A string: either name or two-digit FIPS code of a US state. Required; defaults `"09"` (Connecticut).
#' @param tracts A character vector of 11-digit FIPS codes of tracts to include, or `"all"` for all tracts optionally filtered by county. Defaults `NULL`.
#' @param sumfile A string giving the summary file to pull from. Defaults `"sf1"`; in some rare cases, `"sf3"` may be appropriate.
#' @param verbose Logical: whether to print summary of geographies included. Defaults `TRUE`.
#' @param key String: Census API key. If `NULL` (default), takes the value from `Sys.getenv("CENSUS_API_KEY")`.
#' @param neighborhoods Temporarily deprecated: A named list of neighborhoods with their 11-digit tract GEOIDs (defaults NULL).
#' @return A tibble with GEOID, name, variable code, estimate, moe, geography level, state, and year, as applicable, for the chosen table.
#' @seealso [tidycensus::census_api_key()], [tidycensus::get_decennial()]
#' @examples
#' \dontrun{
#' multi_geo_decennial("P001", 2010,
#'   neighborhoods = list(downtown = c("09009140100", "09009361401", "09009361402"),
#'     dixwell = "090091416"),
#'   towns = "all",
#'   regions = list(inner_ring = c("Hamden", "East Haven", "West Haven")),
#'   counties = "New Haven County")
#' }
#' @export
multi_geo_decennial <- function(table, year = 2010, neighborhoods = NULL, towns = "all", regions = NULL, counties = "all", state = "09", tracts = NULL, sumfile = "sf1", verbose = TRUE, key = NULL) {
  # check key
  if (is.null(key)) {
    key <- Sys.getenv("CENSUS_API_KEY")
  }
  if (nchar(key) == 0) stop("Must supply an API key. See the docs on where to store it.")
  st <- state
  # state must not be null
  assertthat::assert_that(!is.null(st), msg = "Must supply a state name or FIPS code")

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

  # handle situations where table doesn't exist that year/survey
  # avail has table number and concept also
  avail <- decennial_available(table, year, sumfile)
  type <- stringr::str_extract(table, "^(HCT|H|PCT|PCO|P)")
  nmbrs <- stringr::str_extract(table, "\\d+")
  grp <- stringr::str_extract(table, "\\D?$")
  if (!avail[["is_avail"]]) {
    if (is.na(type)) {
      lttrs <- stringr::str_extract(table, "^[[:alpha:]]+")
      msg <- stringr::str_glue("Table numbers should start with one of H, HCT, P, PCT, PCO. {lttrs} is invalid.")
    } else if (nchar(nmbrs) != 3) {
      valid_num <- paste0(type, stringr::str_pad(nmbrs, side = "left", width = 3, pad = "0"), grp)
      msg <- stringr::str_glue("Table {table} looks like an invalid table number. Did you mean {valid_num}?")
    } else {
      msg <- stringr::str_glue("Table {table} for {year} {sumfile} is not available in the API.")
    }
    stop(msg)
  }

  # printout geos
  if (verbose) {
    decennial_vars <- clean_decennial_vars(year = year)
    concept <- decennial_vars %>%
      dplyr::filter(stringr::str_detect(name, paste0("^", table))) %>%
      dplyr::pull(concept) %>%
      `[`(1)
    message(stringr::str_glue("Table {table}: {concept}, {year}"))
    msg <- geo_printout(neighborhoods, towns, regions, counties, st, msa = F, new_england = F)
    message("Geographies included:\n", msg)
  }

  # fetch everything
  fetch <- list()

  # if (!is.null(neighborhoods)) {
  #   fetch$neighborhoods <- decennial_neighborhoods(table, year, neighborhoods, st, sumfile)
  # }
  if (!is.null(tracts)) {
    fips_nchar <- nchar(tracts[1])
    if (!identical(tracts, "all") & fips_nchar != 11) {
      warning(stringr::str_glue("FIPS codes for tracts should have 11 digits, not {fips_nchar}. Tracts will likely be dropped."))
    }
    fetch[["tracts"]] <- decennial_tracts(table, year, tracts, counties, st, sumfile, key)
  }
  if (!is.null(towns)) {
    fetch[["towns"]] <- decennial_towns(table, year, towns, counties, st, sumfile, key)
  }
  if (!is.null(regions)) {
    fetch[["regions"]] <- decennial_regions(table, year, regions, st, sumfile, key)
  }
  if (!is.null(counties)) {
    fetch[["counties"]] <- decennial_counties(table, year, counties, st, sumfile, key)
  }

  fetch[["state"]] <- decennial_state(table, year, st, sumfile, key)

  # take names of all items in fetch, reverse order, make level labels & bind all
  lvls <- rev(fetch)
  list(lvls, names(lvls), 1:length(lvls)) %>%
    purrr::pmap_dfr(function(df, lvl, i) {
      df %>% dplyr::mutate(level = paste(i, lvl, sep = "_"))
    }) %>%
    dplyr::mutate(year = year) %>%
    dplyr::mutate(level = forcats::as_factor(level))
}
