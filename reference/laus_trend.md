# Fetch local area unemployment statistics (LAUS) data over time

Fetch monthly LAUS data for a list of locations over a given time
period, modeled after `blscrapeR::bls_api`. Requires a BLS API key.

## Usage

``` r
laus_trend(
  names = NULL,
  startyear,
  endyear,
  state = "09",
  measures = "all",
  annual = FALSE,
  verbose = TRUE,
  key = NULL
)
```

## Arguments

- names:

  A character vector of place names to look up, either towns and/or
  counties.

- startyear:

  Numeric; first year of range

- endyear:

  Numeric; last year of range

- state:

  A string: either name or two-digit FIPS code of a US state. Required;
  defaults `"09"` (Connecticut).

- measures:

  A character vector of measures, containing any combination of
  `"unemployment rate"`, `"unemployment"`, `"employment"`, or
  `"labor force"`, or `"all"` (the default) as shorthand for all of the
  above.

- annual:

  Logical: whether to include annual averages along with monthly data.
  Defaults `FALSE`.

- verbose:

  Logical: if `TRUE` (default), this will print overview information
  about the series being used, as returned by the API.

- key:

  A string giving the BLS API key. If `NULL` (the default), will take
  the value in `Sys.getenv("BLS_KEY")`.

## Value

A data frame, slightly cleaned up from what the API returns.

## Examples

``` r
if (FALSE) { # \dontrun{
laus_trend(c("Connecticut", "New Haven", "Hamden"), 2014, 2017, annual = TRUE)
} # }
```
