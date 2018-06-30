% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multi_geo_acs.R
\name{multi_geo_acs}
\alias{multi_geo_acs}
\title{Fetch an ACS table with multiple geography levels}
\usage{
multi_geo_acs(table, year = 2016, neighborhoods = NULL, towns = "all",
  regions = NULL, counties = "all", state = "09", us = FALSE)
}
\arguments{
\item{table}{A string giving the ACS table number.}

\item{year}{The year of the ACS table; currently defaults 2016 (most recent available).}

\item{neighborhoods}{A named list of neighborhoods with their 11-digit tract GEOIDs (defaults \code{NULL}).}

\item{towns}{A character vector of towns to include; \code{"all"} (default) for all towns optionally filtered by county; or \code{NULL} to not fetch town-level table.}

\item{regions}{A named list of regions with their town names (defaults \code{NULL}).}

\item{counties}{A character vector of counties to include; \code{"all"} (default) for all counties in the state; or \code{NULL} to not fetch county-level table.}

\item{state}{A string: either name or two-digit FIPS code of a US state. Required; defaults \code{"09"} (Connecticut).}

\item{us}{Logical: whether to fetch US-level table. Defaults \code{FALSE}.}
}
\value{
A tibble with GEOID, name, variable code, estimate, moe, geography level, and county, as applicable, for the chosen ACS table.
}
\description{
Fetch a data table from the ACS via \code{tidycensus} with your choice of geographies at multiple levels. For geographies made of aggregates, i.e. neighborhoods made of tracts or regions made of towns, the returned table will have estimates summed and margins of error calculated for the whole area.
}
\details{
This function essentially calls \code{tidycensus::get_acs} multiple times, depending on geographic levels chosen, and does minor cleaning, filtering, and aggregation. Note that the underlying \code{tidycensus::get_acs} requires a Census API key. As is the case with other \code{tidycensus} functions, \code{multi_geo_acs} assumes this key is stored as \code{CENSUS_API_KEY} in your \code{.Renviron}. See \code{\link[tidycensus:census_api_key]{tidycensus::census_api_key()}} for installation.
}
\examples{
\dontrun{
multi_geo_acs("B01003", 2016,
  neighborhoods = list(downtown = c("09009140100", "09009361401", "09009361402"),
    dixwell = "090091416"),
  towns = "all",
  regions = list(inner_ring = c("Hamden", "East Haven", "West Haven")),
  counties = "New Haven County")
}
}
\seealso{
\code{\link[tidycensus:census_api_key]{tidycensus::census_api_key()}}, \code{\link[tidycensus:get_acs]{tidycensus::get_acs()}}
}