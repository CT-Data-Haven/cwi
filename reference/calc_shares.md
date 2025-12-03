# Make table of rates given a denominator

`calc_shares` makes it easy to divide values by some denominator within
the same long-shaped data frame. For example, it works well for a table
of population groups for multiple locations where you want to divide
population counts by some total population. It optionally handles
dividing margins of error. Denote locations or other groupings by using
a grouped data frame, passing bare column names to `...`, or both.

## Usage

``` r
calc_shares(
  data,
  ...,
  group = group,
  denom = "total_pop",
  value = estimate,
  moe = NULL,
  digits = 2
)
```

## Arguments

- data:

  A data frame

- ...:

  Optional; bare column names to be used for groupings.

- group:

  Bare column name where groups are given–that is, the denominator value
  should be found in this column

- denom:

  String; denominator to filter from `group`

- value:

  Bare column name of values. Replaces previous `estimate` argument, but
  (for now) still defaults to a column named `estimate`

- moe:

  Bare column name of margins of error; if supplied, MOE of shares will
  be included in output

- digits:

  Number of digits to round to; defaults to 2.

## Value

A tibble/data frame with shares (and optionally MOE of shares) of
subgroup values within a denominator group. Shares given for denominator
group will be blank.

## Examples

``` r
edu <- tibble::tribble(
    ~name, ~edu, ~estimate,
    "Hamden", "ages25plus", 41017,
    "Hamden", "bachelors", 8511,
    "Hamden", "graduate", 10621,
    "New Haven", "ages25plus", 84441,
    "New Haven", "bachelors", 14643,
    "New Haven", "graduate", 17223
)
edu |>
    dplyr::group_by(name) |>
    calc_shares(group = edu, denom = "ages25plus", value = estimate)
#> # A tibble: 6 × 4
#> # Groups:   name [2]
#>   name      edu        estimate share
#>   <chr>     <fct>         <dbl> <dbl>
#> 1 Hamden    ages25plus    41017 NA   
#> 2 Hamden    bachelors      8511  0.21
#> 3 Hamden    graduate      10621  0.26
#> 4 New Haven ages25plus    84441 NA   
#> 5 New Haven bachelors     14643  0.17
#> 6 New Haven graduate      17223  0.2 
```
