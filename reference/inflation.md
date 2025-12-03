# Calculate inflation adjustments

`adj_inflation` is modeled after `blscrapeR::inflation_adjust` that
joins a data frame with an inflation adjustment table from the Bureau of
Labor Statistics' Consumer Price Index, then calculates adjusted values.
It returns the original data frame with two additional columns for
adjustment factors and adjustment values. `get_cpi` is a more basic
version of `adj_inflation`. It doesn't adjust your data for you, just
fetches the CPI table used for those adjustments. It handles a couple
options: either seasonally-adjusted or unadjusted, and either annual
averages or monthly values. `adj_inflation`, by contrast, is fixed to
annual and not seasonally adjusted. While `adj_inflation` is a
high-level convenience function, `get_cpi` is better suited to doing
more complex adjustments yourself, such as setting seasonality or
periodicity.

## Usage

``` r
adj_inflation(
  data,
  value,
  year,
  base_year = endyears[["acs"]],
  verbose = TRUE,
  key = NULL
)

get_cpi(
  years,
  base = endyears[["acs"]],
  seasonal = FALSE,
  monthly = FALSE,
  verbose = TRUE,
  key = NULL
)
```

## Source

Bureau of Labor Statistics via their API
<https://www.bls.gov/developers/home.htm>

## Arguments

- data:

  A data frame containing monetary values by year.

- value:

  Bare column name of monetary values; for safety, has no default.

- year:

  Bare column name of years; for safety, has no default.

- base_year:

  Year on which to base inflation amounts. Defaults to 2023, which
  corresponds to saying "... adjusted to 2023 dollars."

- verbose:

  Logical: if `TRUE` (default), this will print overview information
  about the series being used, as returned by the API.

- key:

  A string giving the BLS API key. If `NULL` (the default), will take
  the value in `Sys.getenv("BLS_KEY")`.

- years:

  Numeric vector: years of CPI values to get

- base:

  Base reference point, either a year or a date, or something that can
  be easily coerced to a date. If just a year, will default to January 1
  of that year. Default: 2023

- seasonal:

  Logical, whether to get seasonally-adjusted or unadjusted values.
  Default: FALSE

- monthly:

  Logical. If TRUE, return monthly values. Otherwise, CPI values are
  averaged by the year. Default: FALSE

## Value

For `adj_inflation`: The original data frame with two additional
columns: adjustment factors, and adjusted values. The adjusted values
column is named based on the name supplied as `value`; e.g. if
`value = avg_wage`, the adjusted column is named `adj_avg_wage`.

For `get_cpi`: A data frame/tibble with columns for date (either numeric
years or proper Date objects), CPI value, and adjustment factor based on
the `base` argument.

## Details

**Note:** Because these functions make API calls, internet access is
required.

According to the BLS research page, the series these functions use are
best suited to data going back to about 2000, when their methodology
changed. For previous years, a more accurate version of the index is
available on their
[site](https://www.bls.gov/cpi/research-series/r-cpi-u-rs-home.htm).

## Examples

``` r
if (FALSE) { # \dontrun{
wages <- data.frame(
    fiscal_year = 2010:2016,
    wage = c(50000, 51000, 52000, 53000, 54000, 55000, 54000)
)
adj_inflation(wages, value = wage, year = fiscal_year, base_year = 2016)
} # }
if (FALSE) { # \dontrun{
get_cpi(2018:2024, base = 2024, monthly = FALSE)
get_cpi(2018:2024, base = "2024-12-01", monthly = TRUE)
} # }
```
