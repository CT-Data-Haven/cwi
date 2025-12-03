# Get employment counts and total payroll over time

This gets data from the Quarterly Workforce Indicators (QWI) via the
Census API. It's an alternative to `censusapi` that fetches a set of
variables (employees and payroll) but makes a somewhat more dynamic API
call. The API returns a maximum of 10 years of data; calling this
function with more than 10 years will require multiple API calls, which
takes a little longer.

## Usage

``` r
qwi_industry(
  years,
  industries = cwi::naics_codes[["industry"]],
  state = "09",
  counties = NULL,
  annual = FALSE,
  key = NULL,
  retry = 5
)
```

## Arguments

- years:

  A numeric vector of one or more years for which to get data

- industries:

  A character vector of NAICS industry codes; default is the 20 sectors
  plus "All industries" from the dataset `naics_codes`.

- state:

  A string of length 1 representing a state's FIPS code, name, or
  two-letter abbreviation; defaults to `"09"` for Connecticut

- counties:

  A character vector of county FIPS codes, or `"all"` for all counties.
  If `NULL` (the default), will return data just at the state level. For
  Connecticut, these now need to be COGs; data has been changed
  retroactively.

- annual:

  Logical, whether to return annual averages or quarterly data (default)
  .

- key:

  A Census API key. If `NULL`, defaults to the environmental variable
  `"CENSUS_API_KEY"`, as set by
  [`tidycensus::census_api_key()`](https://walker-data.com/tidycensus/reference/census_api_key.html).

- retry:

  The number of times to retry the API call(s), since the server this
  comes from can be a bit finicky.

## Value

A data frame / tibble

## Details

Note that when looking at data quarterly, the payroll reported will be
for that quarter, not the yearly payroll that you may be more accustomed
to. As of November 2021, payroll data seems to be missing from the
database; even the QWI Explorer app just turns up empty.

## Examples

``` r
if (FALSE) { # \dontrun{
qwi_industry(2012:2017, industries = c("23", "62"), counties = "170")
} # }
```
