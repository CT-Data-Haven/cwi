# this should still work even for null counties--that should just mean erasing counties out of returned data
county_x_state <- function(st, counties) {
  if (is.null(counties)) {
    counties <- "all"
  }
  # take state code, name, or abbrev
  out <- dplyr::filter(tidycensus::fips_codes, state_code == st | state_name == st | state == st)
  out$county_geoid <- paste0(out$state_code, out$county_code)
  if (!identical(counties, "all")) {
    out <- dplyr::filter(out, county_geoid %in% counties)
  }
  out <- dplyr::select(out, state = state_name, county_geoid, county)
  # TODO: hopefully calling fix_cogs works with census api
  if (st == "09") {
    out$county <- ifelse(grepl("^091", out$county_geoid), paste(out$county, "COG"), out$county) # if cog, paste COG on name
  }
  # out$county <- fix_cogs(out$county)
  out
}

get_state_fips <- function(state) {
  xw <- dplyr::distinct(tidycensus::fips_codes, state, state_code, state_name)
  if (grepl("^\\d$", state)) {
    state <- as.numeric(state)
  }
  if (is.numeric(state)) {
    unpad <- state
    state <- sprintf("%02d", state)
    cli::cli_inform("Converting state {unpad} to {state}.")
  }
  if (state %in% xw$state_code) {
    return(state)
  } else if (state %in% xw$state) {
    return(xw$state_code[xw$state == state])
  } else if (state %in% xw$state_name) {
    return(xw$state_code[xw$state_name == state])
  } else {
    return(NULL)
  }
}

get_county_fips <- function(state, counties, use_cogs) {
  xw <- county_x_state(state, "all")
  if (use_cogs) {
    type <- "COG"
  } else {
    type <- "County"
  }

  if (is.null(counties)) {
    counties <- "all"
  }
  if (identical(counties, "all") | identical(counties, "*")) {
    counties <- xw$county_geoid
  } else {
    if (is.numeric(counties)) {
      counties <- sprintf("%s%03d", state, counties)
    }
    counties <- dplyr::case_when(
      grepl("^\\d{3}$", counties)                            ~ paste0(state, counties),
      !grepl("\\d", counties) & !grepl(" County$", counties) & !use_cogs ~ paste(counties, "County"),
      TRUE                                                   ~ counties
    )
    # counties <- fix_cogs(counties)

    cty_from_name <- xw[xw$county %in% counties, ]
    cty_from_fips <- xw[xw$county_geoid %in% counties, ]

    # any counties requested that didn't match?
    matches <- unique(rbind(cty_from_name, cty_from_fips))
    mismatch <- setdiff(counties, c(matches$county, matches$county_geoid))
    if (length(mismatch) > 0) {
      cli::cli_warn("Some counties you requested didn't match for the state {state}: {mismatch}")
    }

    counties <- matches$county_geoid
  }
  if (state == "09") {
    if (use_cogs) {
      counties <- stringr::str_subset(counties, "^090", negate = TRUE)
    } else {
      counties <- stringr::str_subset(counties, "^090", negate = FALSE)
    }
  }
  if (use_cogs) {
    cli::cli_inform(c("i" = "Note that starting with the 2022 release, ACS data uses COGs instead of counties."),
                    .frequency = "once", .frequency_id = "cog")
  }
  counties
}

check_fips_nchar <- function(fips, n_correct) {
  if (!is.null(fips)) {
    n <- nchar(fips)
    if (!identical(fips, "all") & !all(n == n_correct)) {
      return(FALSE)
    } else {
      return(TRUE)
    }
  }
  return(TRUE)
}

# takes e.g. list(tracts = 11, bgs = 12)
nhood_fips_type <- function(fips, n_list) {
  check <- purrr::map(n_list, function(n) check_fips_nchar(fips, n))
  # check <- purrr::keep(check, isTRUE)
  check
}
