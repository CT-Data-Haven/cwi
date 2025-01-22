#' Fetch an ACS table with multiple geography levels
#'
#' Fetch a data table from the ACS via `tidycensus` with your choice of geographies at multiple levels. For geographies made of aggregates, i.e. neighborhoods made of tracts or regions made of towns, the returned table will have estimates summed and margins of error calculated for the whole area. Any geographic levels that are null will be excluded.
#'
#' This function essentially calls `tidycensus::get_acs()` multiple times, depending on geographic levels chosen, and does minor cleaning, filtering, and aggregation. Note that the underlying `tidycensus::get_acs()` requires a Census API key. As is the case with other `tidycensus` functions, `multi_geo_acs` assumes this key is stored as `CENSUS_API_KEY` in your `.Renviron`. See [tidycensus::census_api_key()] for installation.
#'
#' @param table A string giving the ACS table number.
#' @param year The year of the ACS table; currently defaults `r cwi:::endyears[["acs"]]` (most recent available).
#' @param towns A character vector of names of towns to include; `"all"` (default) for all towns optionally filtered by county; or `NULL` to not fetch town-level table.
#' @param regions A named list of regions with their town names (defaults `NULL`).
#' @param counties A character vector of names of counties to include; `"all"` (default) for all counties in the state; or `NULL` to not fetch county-level table.
#' @param state A string: either name or two-digit FIPS code of a US state. Required; defaults `"09"` (Connecticut).
#' @param neighborhoods A data frame with columns for neighborhood name, GEOID of either tracts or block groups, and weight, e.g. share of each tract assigned to a neighborhood. If included, weighted sums and MOEs will be returned for neighborhoods. Try to match the formatting of the [built-in neighborhood tables][neighborhood_tracts].
#' @param tracts A character vector of 11-digit FIPS codes of tracts to include, or `"all"` for all tracts optionally filtered by county. Defaults `NULL`.
#' @param blockgroups A character vector of 12-digit FIPS codes of block groups to include, or `"all"` for all block groups optionally filtered by county. Defaults `NULL`.
#' @param pumas A character vector of 7-digit FIPS codes of public use microdata areas (PUMAs) to include, or `"all"` for all PUMAs optionally filtered by county. It's up to you to filter out any redundancies--some large towns are standalone PUMAs, as are some sparsely-population counties. Defaults `NULL`.
#' @param msa Logical: whether to fetch New England states' metropolitan statistical areas. Defaults `FALSE`.
#' @param us Logical: whether to fetch US-level table. Defaults `FALSE`.
#' @param new_england Logical: if `TRUE` (the default), limits metro areas to just New England states.
#' @param nhood_name String giving the name of the column in the data frame `neighborhoods` that contains neighborhood names. Previously this was a bare column name, but for consistency with changes to COG-based FIPS codes, this needs to be a string. Only relevant if a neighborhood weight table is being used. Defaults `"name"` to match the neighborhood lookup datasets.
#' @param nhood_geoid String giving the name of the column in `neighborhoods` that contains neighborhood GEOIDs, either tracts or block groups. Only relevant if a neighborhood weight table is being used. Because of changes to FIPS codes, this no longer has a default.
#' @param nhood_weight String giving the name of the column in `neighborhoods` that contains weights between neighborhood names and tract/block groups. Only relevant if a neighborhood weight table is being used. Defaults `"weight"` to match the neighborhood lookup datasets.
#' @param survey A string: which ACS estimate to use. Defaults to 5-year (`"acs5"`), but can also be 1-year (`"acs1"`).
#' @param verbose Logical: whether to print summary of geographies included. Defaults `TRUE`.
#' @param key String: Census API key. If `NULL` (default), takes the value from `Sys.getenv("CENSUS_API_KEY")`.
#' @param sleep Number of seconds, if any, to sleep before each API call. This might help with the Census API's tendency to crash, but for many geographies, it could add a sizable about of time. Probably don't add more than a few seconds.
#' @param ... Additional arguments to pass on to `tidycensus::get_acs`
#' @return A tibble with GEOID, name, variable code, estimate, moe, geography level, state, and year, as applicable, for the chosen ACS table.
#' @seealso [tidycensus::census_api_key()], [tidycensus::get_acs()]
#' @examples
#' \dontrun{
#' multi_geo_acs("B01003", 2019,
#'     towns = "all",
#'     regions = list(inner_ring = c("Hamden", "East Haven", "West Haven")),
#'     counties = "New Haven County",
#'     tracts = unique(new_haven_tracts$geoid)
#' )
#'
#' multi_geo_acs("B01003", 2018,
#'     towns = "Bridgeport",
#'     counties = "Fairfield County",
#'     neighborhoods = bridgeport_tracts
#' )
#' }
#' @export
multi_geo_acs <- function(table, year = endyears[["acs"]],
                          towns = "all", regions = NULL,
                          counties = "all", state = "09", neighborhoods = NULL,
                          tracts = NULL, blockgroups = NULL,
                          pumas = NULL, msa = FALSE,
                          us = FALSE, new_england = TRUE,
                          nhood_name = "name", nhood_geoid = NULL, nhood_weight = "weight",
                          survey = c("acs5", "acs1"),
                          verbose = TRUE, key = NULL, sleep = 0, ...) {
    survey <- rlang::arg_match(survey)
    # because of switch to COGs, removed default geoid---check for null

    ## PARAMS & ERROR HANDLING ----
    params <- multi_geo_prep(
        src = "acs",
        table = table,
        year = year,
        towns = towns,
        regions = regions,
        counties = counties,
        state = state,
        neighborhoods = neighborhoods,
        tracts = tracts,
        blockgroups = blockgroups,
        pumas = pumas,
        msa = msa,
        us = us,
        new_england = new_england,
        # nhood_name = {{ nhood_name }},
        # nhood_geoid = {{ nhood_geoid }},
        nhood_name = nhood_name,
        nhood_geoid = nhood_geoid,
        dataset = survey,
        verbose = verbose,
        key = key
    )

    ## at this point, tables, geos, etc have been validated
    state_fips <- params$state_fips
    counties_fips <- params$counties_fips
    nhood_is_tract <- params$nhood_is_tract

    ## FETCH STUFF ----
    fetch <- list()

    # block groups: bg fips, county
    if (!is.null(blockgroups)) {
        fetch[["blockgroup"]] <- census_blockgroups("acs", table, year, blockgroups, counties_fips, state_fips, survey, key, sleep, ...)
    }

    # tracts: tract fips, county
    if (!is.null(tracts)) {
        fetch[["tract"]] <- census_tracts("acs", table, year, tracts, counties_fips, state_fips, survey, key, sleep, ...)
    }

    # neighborhoods: nhood data frame, nhood columns
    if (!is.null(neighborhoods)) {
        fetch[["neighborhood"]] <- census_nhood(
            "acs", table, year, neighborhoods, state_fips,
            nhood_name, nhood_geoid, nhood_weight,
            nhood_is_tract, estimate, survey, key, sleep, ...
        )
    }

    # towns: towns, county
    if (!is.null(towns)) {
        fetch[["town"]] <- census_towns("acs", table, year, towns, counties_fips, state_fips, survey, key, sleep, ...)
    }

    # pumas
    if (!is.null(pumas)) {
        fetch[["puma"]] <- census_pumas("acs", table, year, pumas, counties_fips, state_fips, survey, key, sleep, ...)
    }

    # regions: region-town list
    if (!is.null(regions)) {
        fetch[["region"]] <- census_regions("acs", table, year, regions, state_fips, estimate, survey, key, sleep, ...)
    }

    # counties
    if (!is.null(counties)) {
        fetch[["county"]] <- census_counties("acs", table, year, counties_fips, state_fips, survey, key, sleep, ...)
    }

    # state
    fetch[["state"]] <- census_state("acs", table, year, state_fips, survey, key, sleep, ...)

    # msa: new england
    if (msa) {
        fetch[["msa"]] <- census_msa("acs", table, year, new_england, survey, key, sleep, ...)
    }

    # us
    if (us) {
        fetch[["us"]] <- census_us("acs", table, year, survey, key, sleep, ...)
    }

    ## BIND + RETURN ----
    # take names of non-null items, reverse order
    fetch <- rev(fetch)
    fetch <- rlang::set_names(fetch, function(nm) paste(seq_along(fetch), nm, sep = "_"))
    fetch <- purrr::map(fetch, janitor::clean_names)
    fetch_df <- dplyr::bind_rows(fetch, .id = "level")
    fetch_df$year <- year
    fetch_df$level <- as.factor(fetch_df$level)
    fetch_df <- dplyr::select(
        fetch_df, tidyselect::any_of(c("year", "level", "state", "county", "geoid")),
        tidyselect::everything()
    )
    fetch_df
}

#' Fetch a decennial census table with multiple geography levels
#'
#' Fetch a data table from the decennial census via `tidycensus` with your choice of geographies at multiple levels. For geographies made of aggregates, i.e. neighborhoods made of tracts or regions made of towns, the returned table will have estimates summed for the whole area. Any geographic levels that are null will be excluded.
#'
#' This function essentially calls `tidycensus::get_decennial()` multiple times, depending on geographic levels chosen, and does minor cleaning, filtering, and aggregation. Note that the underlying `tidycensus::get_decennial()` requires a Census API key. As is the case with other `tidycensus` functions, `multi_geo_decennial` assumes this key is stored as `CENSUS_API_KEY` in your `.Renviron`. See [tidycensus::census_api_key()] for installation.
#'
#' Be advised that decennial table numbers may change from year to year, so if you're looking at trends, check FactFinder or another source to make sure the tables have the same meaning. Setting `verbose = TRUE` is helpful for this as well.
#'
#' @param table A string giving the decennial census table number. These are generally formatted as one or more letters, 3 numbers, and optionally a letter.
#' @param year The year of the census table; currently defaults `r cwi:::endyears[["decennial"]]`.
#' @param towns A character vector of towns to include; `"all"` (default) for all towns optionally filtered by county; or `NULL` to not fetch town-level table.
#' @param regions A named list of regions with their town names (defaults `NULL`).
#' @param counties A character vector of counties to include; `"all"` (default) for all counties in the state; or `NULL` to not fetch county-level table.
#' @param state A string: either name or two-digit FIPS code of a US state. Required; defaults `"09"` (Connecticut).
#' @param neighborhoods A data frame with columns for neighborhood name, GEOID of tracts, and weight, e.g. share of each tract assigned to a neighborhood. If included, weighted sums will be returned for neighborhoods. Unlike `multi_geo_acs`, this doesn't take block groups.
#' @param tracts A character vector of 11-digit FIPS codes of tracts to include, or `"all"` for all tracts optionally filtered by county. Defaults `NULL`.
#' @param blockgroups A character vector of 12-digit FIPS codes of block groups to include, or `"all"` for all block groups optionally filtered by county. Defaults `NULL`.
#' @param msa Logical: whether to fetch New England states' metropolitan statistical areas. Defaults `FALSE`.
#' @param us Logical: whether to fetch US-level table. Defaults `FALSE`.
#' @param new_england Logical: if `TRUE` (the default), limits metro areas to just New England states.
#' @param nhood_name String giving the name of the column in the data frame `neighborhoods` that contains neighborhood names. Previously this was a bare column name, but for consistency with changes to COG-based FIPS codes, this needs to be a string. Only relevant if a neighborhood weight table is being used. Defaults `"name"` to match the neighborhood lookup datasets.
#' @param nhood_geoid String giving the name of the column in `neighborhoods` that contains neighborhood GEOIDs, either tracts or block groups. Only relevant if a neighborhood weight table is being used. Because of changes to FIPS codes, this no longer has a default.
#' @param nhood_weight String giving the name of the column in `neighborhoods` that contains weights between neighborhood names and tract/block groups. Only relevant if a neighborhood weight table is being used. Defaults `"weight"` to match the neighborhood lookup datasets.
#' @param sumfile A string giving the summary file to pull from. Note that codes have changed between 2010 and 2020. Now that default year is 2020, default sumfile is `"dhc"`. For 2010, should be either `"sf1"`, or less commonly `"sf3"`. Use `"pl"` for 2020 redistricting data.
#' @param verbose Logical: whether to print summary of geographies included. Defaults `TRUE`.
#' @param key String: Census API key. If `NULL` (default), takes the value from `Sys.getenv("CENSUS_API_KEY")`.
#' @param sleep Number of seconds, if any, to sleep before each API call. This might help with the Census API's tendency to crash, but for many geographies, it could add a sizable about of time. Probably don't add more than a few seconds.
#' @param ... Additional arguments to pass on to `tidycensus::get_acs`
#' @return A tibble with GEOID, name, variable code, estimate, moe, geography level, state, and year, as applicable, for the chosen table.
#' @seealso [tidycensus::census_api_key()], [tidycensus::get_decennial()]
#' @examples
#' \dontrun{
#' multi_geo_decennial("P1", 2020,
#'     sumfile = "dhc",
#'     towns = "all",
#'     regions = list(inner_ring = c("Hamden", "East Haven", "West Haven")),
#'     counties = "New Haven County"
#' )
#' }
#' @export
multi_geo_decennial <- function(table, year = endyears[["decennial"]],
                                towns = "all", regions = NULL,
                                counties = "all", state = "09", neighborhoods = NULL,
                                tracts = NULL, blockgroups = NULL, msa = FALSE,
                                us = FALSE, new_england = TRUE,
                                nhood_name = "name", nhood_geoid = NULL, nhood_weight = "weight",
                                sumfile = c("dhc", "sf1", "sf3", "pl"),
                                verbose = TRUE, key = NULL, sleep = 0, ...) {
    sumfile <- rlang::arg_match(sumfile)

    ## PARAMS & ERROR HANDLING ----
    params <- multi_geo_prep(
        src = "decennial",
        table = table,
        year = year,
        towns = towns,
        regions = regions,
        counties = counties,
        state = state,
        neighborhoods = neighborhoods,
        tracts = tracts,
        blockgroups = blockgroups,
        pumas = NULL, # not available for decennial
        msa = msa,
        us = us,
        new_england = new_england,
        nhood_name = nhood_name, nhood_geoid = nhood_geoid,
        dataset = sumfile,
        verbose = verbose,
        key = key
    )

    ## at this point, tables, geos, etc have been validated
    state_fips <- params$state_fips
    counties_fips <- params$counties_fips
    nhood_is_tract <- params$nhood_is_tract

    ## FETCH STUFF ----
    fetch <- list()

    # block groups: bg fips, county
    if (!is.null(blockgroups)) {
        fetch[["blockgroup"]] <- census_blockgroups("decennial", table, year, blockgroups, counties_fips, state_fips, sumfile, key, sleep, ...)
    }

    # tracts: tract fips, county
    if (!is.null(tracts)) {
        fetch[["tract"]] <- census_tracts("decennial", table, year, tracts, counties_fips, state_fips, sumfile, key, sleep, ...)
    }

    # neighborhoods: nhood data frame, nhood columns
    if (!is.null(neighborhoods)) {
        fetch[["neighborhood"]] <- census_nhood(
            "decennial", table, year, neighborhoods, state_fips,
            nhood_name, nhood_geoid, nhood_weight,
            nhood_is_tract, value, sumfile, key, sleep, ...
        )
    }

    # towns: towns, county
    if (!is.null(towns)) {
        fetch[["town"]] <- census_towns("decennial", table, year, towns, counties_fips, state_fips, sumfile, key, sleep, ...)
    }

    # regions: region-town list
    if (!is.null(regions)) {
        fetch[["region"]] <- census_regions("decennial", table, year, regions, state_fips, value, sumfile, key, sleep, ...)
    }

    # counties
    if (!is.null(counties)) {
        fetch[["county"]] <- census_counties("decennial", table, year, counties_fips, state_fips, sumfile, key, sleep, ...)
    }

    # state
    fetch[["state"]] <- census_state("decennial", table, year, state_fips, sumfile, key, sleep, ...)

    # msa: new england
    if (msa) {
        fetch[["msa"]] <- census_msa("decennial", table, year, new_england, sumfile, key, sleep, ...)
    }

    # us
    if (us) {
        fetch[["us"]] <- census_us("decennial", table, year, sumfile, key, sleep, ...)
    }

    ## BIND + RETURN ----
    # take names of non-null items, reverse order
    fetch <- rev(fetch)
    fetch <- rlang::set_names(fetch, function(nm) paste(seq_along(fetch), nm, sep = "_"))
    fetch <- purrr::map(fetch, janitor::clean_names)
    fetch_df <- dplyr::bind_rows(fetch, .id = "level")
    fetch_df$year <- year
    fetch_df$level <- as.factor(fetch_df$level)
    fetch_df <- dplyr::select(
        fetch_df, tidyselect::all_of(c("year", "level", "state", "county", "geoid")),
        tidyselect::everything()
    )
    fetch_df
}

############ PREP ----

multi_geo_prep <- function(src,
                           table, year, towns, regions,
                           counties, state, neighborhoods,
                           tracts, blockgroups,
                           pumas, msa,
                           us, new_england,
                           nhood_name, nhood_geoid,
                           dataset, verbose, key) {
    ## ERROR & META HANDLING ----
    # check dataset
    NCHAR_TRACT <- 11
    NCHAR_BG <- 12
    NCHAR_PUMA <- 7

    # COG SWITCH!!
    # check whether to use COGs--true if src == acs & year >= 2022
    # check state, convert / copy to fips
    if (is.null(state) | length(state) > 1) {
        cli::cli_abort("Must supply a single state by name, abbreviation, or FIPS code.",
            call = parent.frame()
        )
    }
    state_fips <- get_state_fips(state)
    if (is.null(state_fips)) {
        cli::cli_abort("{state} is not a valid state name, abbreviation, or FIPS code.",
            call = parent.frame()
        )
    }
    use_cogs <- src == "acs" & year >= 2022 & state_fips == "09"

    # check key
    key <- check_census_key(key)
    if (is.logical(key) && !key) {
        cli::cli_abort("Must supply an API key. See the docs on where to store it.",
            call = parent.frame()
        )
    }

    # check valid table / year / dataset
    # available functions will return false if not found
    dataset_title <- dataset_available(src, year, dataset)

    if (is.logical(dataset_title) && !dataset_title) {
        cli::cli_abort(
            c("Dataset {dataset} for year {year} is not available in the API.",
                "i" = "Check {.var cb_avail} to see what combinations of years and datasets are available."
            ),
            call = parent.frame()
        )
    }

    tbl_title <- table_available(src, table, year, dataset)
    if (is.logical(tbl_title) && !tbl_title) {
        if (src == "decennial") {
            digits_msg <- "Note that decennial table numbers might need to be padded with zeroes."
        } else {
            digits_msg <- NULL
        }
        # msg <- rlang::set_names(c(sprintf("Try looking through the corresponding {.var %s_vars} dataset", src), digits_msg), "i")
        cli::cli_abort(
            c("Table {table} for {year} {dataset} is not available in the API.",
                "i" = "Try calling {.fn tidycensus::load_variables} to see what variables are available."
            ),
            call = parent.frame()
        )
    }

    # check for nhood_geoid---needs to be explicitly provided now
    if (!is.null(neighborhoods) & !is.character(nhood_geoid)) {
        cli::cli_abort(c("The default value of {.arg nhood_geoid} has been removed. To get neighborhood aggregations, please supply {.arg nhood_geoid} explicitly.",
            "i" = "Note that these columns should now be given as strings, not bare names."
        ))
    }

    # validate county names, convert to 5-digit fips
    drop_counties <- is.null(counties)

    counties_fips <- get_county_fips(state_fips, counties, use_cogs)
    xw <- county_x_state(state_fips, counties_fips)

    # check number of characters in fips codes
    if (!check_fips_nchar(tracts, NCHAR_TRACT)) {
        cli::cli_warn("FIPS codes for tracts should have {NCHAR_TRACT} digits, not {nchar(tracts)[1]}; tracts will be dropped.")
        tracts <- NULL
    }
    if (!check_fips_nchar(blockgroups, NCHAR_BG)) {
        cli::cli_warn("FIPS codes for block groups should have {NCHAR_BG} digits, not {nchar(blockgroups)[1]}; block groups will be dropped.")
        blockgroups <- NULL
    }
    if (!check_fips_nchar(pumas, NCHAR_PUMA)) {
        cli::cli_warn("FIPS codes for PUMAs should have {NCHAR_PUMA} digits, not {nchar(pumas)[1]}; PUMAs will be dropped.")
        pumas <- NULL
    }

    # are neighborhood fips for tracts or bgs?
    if (!is.null(neighborhoods)) {
        nhood_valid_fips <- nhood_fips_type(
            neighborhoods[[nhood_geoid]],
            list(tracts = NCHAR_TRACT, block_groups = NCHAR_BG)
        )
        nhood_is_tract <- nhood_valid_fips[["tracts"]]

        valid <- any(unlist(nhood_valid_fips))
        if (!valid) {
            cli::cli_alert_warning("FIPS codes for neighborhoods didn't match either tracts or block groups; neighborhoods will be dropped.")
            neighborhoods <- NULL
            nhood_valid_fips <- NULL
            nhood_is_tract <- NULL
        }
    } else {
        nhood_valid_fips <- NULL
        nhood_is_tract <- NULL
    }


    ## PRINTOUTS ----
    if (verbose) {
        # printable list of all geographies
        if (is.null(neighborhoods)) {
            nhood_names <- NULL
        } else {
            nhood_names <- unique(dplyr::pull(neighborhoods, {{ nhood_name }}))
        }
        all_counties <- identical(counties, "all")
        geos_to_print <- list(
            blockgroups = blockgroups,
            tracts = tracts,
            neighborhoods = nhood_names,
            towns = towns,
            regions = names(regions),
            pumas = pumas,
            counties = xw$county,
            all_counties = all_counties,
            drop_counties = drop_counties,
            state = state,
            msa = msa,
            us = us,
            new_england = new_england,
            nhood_type = nhood_valid_fips,
            use_cogs = use_cogs
        )
        # print title
        rlang::exec(table_printout, !!!tbl_title)
        # print geographies
        rlang::exec(geo_printout, !!!geos_to_print)
    }

    # return state fips, county fips, nhood is tract--others handled okay by acs/dec functions
    params <- list(
        state_fips = state_fips,
        counties_fips = counties_fips,
        drop_counties = drop_counties,
        nhood_is_tract = nhood_is_tract
    )
    params
}
