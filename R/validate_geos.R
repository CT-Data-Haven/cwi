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

get_county_fips <- function(state, counties) {
  xw <- county_x_state(state, "all")

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
      !grepl("\\d", counties) & !grepl(" County$", counties) ~ paste(counties, "County"),
      TRUE                                                   ~ counties
    )

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
