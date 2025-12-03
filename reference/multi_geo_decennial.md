# Fetch a decennial census table with multiple geography levels

Fetch a data table from the decennial census via `tidycensus` with your
choice of geographies at multiple levels. For geographies made of
aggregates, i.e. neighborhoods made of tracts or regions made of towns,
the returned table will have estimates summed for the whole area. Any
geographic levels that are null will be excluded.

## Usage

``` r
multi_geo_decennial(
  table,
  year = endyears[["decennial"]],
  towns = "all",
  regions = NULL,
  counties = "all",
  state = "09",
  neighborhoods = NULL,
  tracts = NULL,
  blockgroups = NULL,
  msa = FALSE,
  us = FALSE,
  new_england = TRUE,
  nhood_name = "name",
  nhood_geoid = NULL,
  nhood_weight = "weight",
  sumfile = c("dhc", "sf1", "sf3", "pl"),
  verbose = TRUE,
  key = NULL,
  sleep = 0,
  ...
)
```

## Arguments

- table:

  A string giving the decennial census table number. These are generally
  formatted as one or more letters, 3 numbers, and optionally a letter.

- year:

  The year of the census table; currently defaults 2020.

- towns:

  A character vector of towns to include; `"all"` (default) for all
  towns optionally filtered by county; or `NULL` to not fetch town-level
  table.

- regions:

  A named list of regions with their town names (defaults `NULL`).

- counties:

  A character vector of counties to include; `"all"` (default) for all
  counties in the state; or `NULL` to not fetch county-level table.

- state:

  A string: either name or two-digit FIPS code of a US state. Required;
  defaults `"09"` (Connecticut).

- neighborhoods:

  A data frame with columns for neighborhood name, GEOID of tracts, and
  weight, e.g. share of each tract assigned to a neighborhood. If
  included, weighted sums will be returned for neighborhoods. Unlike
  `multi_geo_acs`, this doesn't take block groups.

- tracts:

  A character vector of 11-digit FIPS codes of tracts to include, or
  `"all"` for all tracts optionally filtered by county. Defaults `NULL`.

- blockgroups:

  A character vector of 12-digit FIPS codes of block groups to include,
  or `"all"` for all block groups optionally filtered by county.
  Defaults `NULL`.

- msa:

  Logical: whether to fetch New England states' metropolitan statistical
  areas. Defaults `FALSE`.

- us:

  Logical: whether to fetch US-level table. Defaults `FALSE`.

- new_england:

  Logical: if `TRUE` (the default), limits metro areas to just New
  England states.

- nhood_name:

  String giving the name of the column in the data frame `neighborhoods`
  that contains neighborhood names. Previously this was a bare column
  name, but for consistency with changes to COG-based FIPS codes, this
  needs to be a string. Only relevant if a neighborhood weight table is
  being used. Defaults `"name"` to match the neighborhood lookup
  datasets.

- nhood_geoid:

  String giving the name of the column in `neighborhoods` that contains
  neighborhood GEOIDs, either tracts or block groups. Only relevant if a
  neighborhood weight table is being used. Because of changes to FIPS
  codes, this no longer has a default.

- nhood_weight:

  String giving the name of the column in `neighborhoods` that contains
  weights between neighborhood names and tract/block groups. Only
  relevant if a neighborhood weight table is being used. Defaults
  `"weight"` to match the neighborhood lookup datasets.

- sumfile:

  A string giving the summary file to pull from. Note that codes have
  changed between 2010 and 2020. Now that default year is 2020, default
  sumfile is `"dhc"`. For 2010, should be either `"sf1"`, or less
  commonly `"sf3"`. Use `"pl"` for 2020 redistricting data.

- verbose:

  Logical: whether to print summary of geographies included. Defaults
  `TRUE`.

- key:

  String: Census API key. If `NULL` (default), takes the value from
  `Sys.getenv("CENSUS_API_KEY")`.

- sleep:

  Number of seconds, if any, to sleep before each API call. This might
  help with the Census API's tendency to crash, but for many
  geographies, it could add a sizable about of time. Probably don't add
  more than a few seconds.

- ...:

  Arguments passed on to
  [`tidycensus::get_decennial`](https://walker-data.com/tidycensus/reference/get_decennial.html)

  `variables`

  :   Character string or vector of character strings of variable IDs.

  `county`

  :   The county for which you are requesting data. County names and
      FIPS codes are accepted. Must be combined with a value supplied to
      \`state\`. Defaults to NULL.

  `geometry`

  :   if FALSE (the default), return a regular tibble of ACS data. if
      TRUE, uses the tigris package to return an sf tibble with simple
      feature geometry in the \`geometry\` column.

  `output`

  :   One of "tidy" (the default) in which each row represents an
      enumeration unit-variable combination, or "wide" in which each row
      represents an enumeration unit and the variables are in the
      columns.

  `keep_geo_vars`

  :   if TRUE, keeps all the variables from the Census shapefile
      obtained by tigris. Defaults to FALSE.

  `shift_geo`

  :   (deprecated) if TRUE, returns geometry with Alaska and Hawaii
      shifted for thematic mapping of the entire US. Geometry was
      originally obtained from the albersusa R package. As of May 2021,
      we recommend using
      [`tigris::shift_geometry()`](https://rdrr.io/pkg/tigris/man/shift_geometry.html)
      instead.

  `summary_var`

  :   Character string of a "summary variable" from the decennial Census
      to be included in your output. Usually a variable (e.g. total
      population) that you'll want to use as a denominator or
      comparison.

  `pop_group`

  :   The population group code for which you'd like to request data.
      Applies to summary files for which population group breakdowns are
      available like the Detailed DHC-A file.

  `pop_group_label`

  :   If `TRUE`, return a `"pop_group_label"` column that contains the
      label for the population group. Defaults to `FALSE`.

  `show_call`

  :   if TRUE, display call made to Census API. This can be very useful
      in debugging and determining if error messages returned are due to
      tidycensus or the Census API. Copy to the API call into a browser
      and see what is returned by the API directly. Defaults to FALSE.

## Value

A tibble with GEOID, name, variable code, estimate, moe, geography
level, state, and year, as applicable, for the chosen table.

## Details

This function essentially calls
[`tidycensus::get_decennial()`](https://walker-data.com/tidycensus/reference/get_decennial.html)
multiple times, depending on geographic levels chosen, and does minor
cleaning, filtering, and aggregation. Note that the underlying
[`tidycensus::get_decennial()`](https://walker-data.com/tidycensus/reference/get_decennial.html)
requires a Census API key. As is the case with other `tidycensus`
functions, `multi_geo_decennial` assumes this key is stored as
`CENSUS_API_KEY` in your `.Renviron` or other source of environment
variables. See
[`tidycensus::census_api_key()`](https://walker-data.com/tidycensus/reference/census_api_key.html)
for installation.

Be advised that decennial table numbers generally change from year to
year, so if you're looking at trends, check
[data.census.gov](https://data.census.gov) or another source to make
sure the tables have the same meaning. Setting `verbose = TRUE` is
helpful for this as well.

## See also

[`tidycensus::census_api_key()`](https://walker-data.com/tidycensus/reference/census_api_key.html),
[`tidycensus::get_decennial()`](https://walker-data.com/tidycensus/reference/get_decennial.html)

## Examples

``` r
if (FALSE) { # \dontrun{
multi_geo_decennial("P1", 2020,
    sumfile = "dhc",
    towns = "all",
    regions = list(inner_ring = c("Hamden", "East Haven", "West Haven")),
    counties = "New Haven County"
)
} # }
```
