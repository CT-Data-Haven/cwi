# Check availability of datasets

These two functions check for the availability of datasets needed to
formulate API queries.

- `check_cb_avail` finds all available vintages of major surveys under
  the Census Bureau's ACS and Decennial programs for the mainland US.

- `check_qwi_avail` finds all years of QWI data available per state.

Previously, these were datasets built into the package, which ran the
risk of being outdated and therefore missing the availability of new
data. These functions need to read data from the internet, but are
memoized so that the results are reasonably up-to-date without having to
make API calls repeatedly.

## Usage

``` r
check_cb_avail()

check_qwi_avail()
```

## Value

**For `check_cb_avail`**: A data frame with columns for vintage, program
(e.g. "acs"), survey (e.g. "acs5"), and title, as returned from the
Census Bureau API.

**For check_qwi_avail\`**: A data frame with columns for state FIPS
code, earliest year available, and most recent year available.

## See also

[US Census Bureau API Discovery
Tool](https://www.census.gov/data/developers/updates/new-discovery-tool.html)
[LED Extraction Tool](https://ledextract.ces.census.gov/)

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive()) {
    cb_avail <- check_cb_avail()
    cb_avail |>
        dplyr::filter(program == "dec", vintage == 2020)
}
} # }
if (FALSE) { # \dontrun{
if (interactive()) {
    qwi_avail <- check_qwi_avail()
    qwi_avail |>
        dplyr::filter(state_code == "09")
}
} # }
```
