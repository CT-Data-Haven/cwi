# Quickly add the labels of census variables

`multi_geo_*` functions, and their underlying `tidycensus::get_*`
functions, return data tables with variable codes (e.g. "B01001_003"),
which can be joined with lookup tables to get readable labels (e.g.
"Total!!Male!!Under 5 years"). These functions are just quick wrappers
around the common task of joining your data frame with the variable
codes and labels.

## Usage

``` r
label_decennial(data, year = 2020, sumfile = "dhc", variable = variable)

label_acs(data, year = 2023, survey = "acs5", variable = variable)
```

## Arguments

- data:

  A data frame/tibble.

- year:

  The year of data; defaults to 2023 for ACS, or 2020 for decennial.

- sumfile:

  For `label_decennial`, a string: which summary file to use. Defaults
  to `"dhc"`, the code used for 2020. 2010 used summary files labeled
  `"sf1"` or `"sf3"`.

- variable:

  The bare column name of variable codes; defaults to `variable`, as
  returned by the `multi_geo_*` or `tidycensus::get_*` functions.

- survey:

  For `label_acs`, a string: which ACS estimate to use. Defaults to
  5-year (`"acs5"`), but can also be 1-year (`"acs1"`) or 3-year
  (`"acs3"`), though both 1-year and 3-year have limited availability.

## Value

A tibble with the same number of rows as `data` but an additional column
called `label`

## See also

[decennial_vars](https://CT-Data-Haven.github.io/cwi/reference/decennial_vars.md)
[acs_vars](https://CT-Data-Haven.github.io/cwi/reference/acs_vars.md)

## Examples

``` r
if (FALSE) { # \dontrun{
acs_pops <- multi_geo_acs("B01001")
label_acs(acs_pops)
} # }
```
