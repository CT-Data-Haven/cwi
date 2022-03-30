# make geography printout--not exported
bold_hdr <- function(place_name, place_type) {
  sprintf("{.strong %s:} %s", place_type, paste(place_name, collapse = ", "))
}

######## CENSUS: ACS + DECENNIAL ----
geo_printout <- function(neighborhoods, tracts, blockgroups, towns, regions, counties, all_counties, drop_counties, state, msa, us, new_england, nhood_type) {
  geos <- tibble::lst(neighborhoods, tracts, blockgroups, towns, regions, counties, state)
  if (drop_counties) {
    geos$counties <- NULL
  }
  # basically writing own imap_at
  subgeos <- c("neighborhoods", "tracts", "blockgroups", "towns")
  geos[subgeos] <- purrr::map(subgeos, function(geo_hdr) {
    geo <- geos[[geo_hdr]]
    if (is.null(geo)) {
      geo_txt <- NULL
    } else if (identical(geo, "all")) {
      if (all_counties) {
        county_str <- "all counties"
      } else {
        county_str <- "{counties}"
      }
      geo_txt <- sprintf("all %s in %s", geo_hdr, county_str)
    } else {
      if (geo_hdr == "towns") {
        geo_txt <- geo
      } else {
        geo_txt <- paste(length(unique(geo)), geo_hdr)
      }
    }
    geo_txt
  })
  geos <- rlang::set_names(geos, stringr::str_to_sentence)

  if (msa) {
    if (new_england) {
      geos[["MSA"]] <- "All in New England"
    } else {
      geos[["MSA"]] <- "All in US"
    }
  }
  if (us) {
    geos[["US"]] <- "Yes"
  }
  geos <- purrr::compact(geos)
  geos <- purrr::imap(geos, bold_hdr)
  cli::cli_ul(items = geos, .close = TRUE)

  # alert about using tracts for nhoods
  if (!is.null(nhood_type)) {
    # should only eval true for one item in list, although i guess theoretically that might be wrong...
    nhood_type <- purrr::keep(nhood_type, isTRUE)
    # message(cli::format_message(c("i" = "Assuming that neighborhood GEOIDs are for {names(nhood_type)}.")))
    cli::cli_alert_info("Assuming that neighborhood GEOIDs are for {names(nhood_type)}.")
  }
}


table_printout <- function(table, concept, year) {
  cli::cli_h1("Table {table}: {concept}, {year}")
}


######## BLS ----
bls_series_printout <- function(fetch) {
  catalog <- fetch[["catalog"]]
  series_title <- catalog[["series_title"]]
  series_title <- gsub("\\:.+$", "", series_title)
  series_title <- unique(series_title)
  series_title <- paste(series_title, collapse = ", ")

  survey <- unique(catalog[["survey_name"]])

  if (grepl("seasonal", series_title)) {
    season <- NULL
  } else {
    season <- unique(catalog[["seasonality"]])
  }

  cli::cli_h1("{survey}")
  cli::cli_ul(c(series_title, season))
}
