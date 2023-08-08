
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cwi <img src="man/figures/logo.png" align="right" />

<!-- badges: start -->

[![check-release](https://github.com/CT-Data-Haven/cwi/actions/workflows/check-release.yaml/badge.svg)](https://github.com/CT-Data-Haven/cwi/actions/workflows/check-release.yaml)
[![pkgdown](https://github.com/CT-Data-Haven/cwi/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/CT-Data-Haven/cwi/actions/workflows/pkgdown.yaml)
[![Codecov test
coverage](https://codecov.io/gh/CT-Data-Haven/cwi/branch/main/graph/badge.svg)](https://app.codecov.io/gh/CT-Data-Haven/cwi?branch=main)
<!-- badges: end -->

The original goal of `cwi` was to get data, primarily the Census ACS,
fetched, aggregated, and analyzed for [DataHaven’s 2019 Community Index
reports](http://ctdatahaven.org/reports/greater-new-haven-community-index).
It’s now evolved to support more of our day-to-day work—and now we’re on
the 2022 reports! This includes functions to speed up and standardize
analysis for multiple staff people, preview trends and patterns we’ll
need to write about, and get data in more layperson-friendly formats.

It pairs well with many functions from Camille’s brilliantly-named
[`camiller`](https://github.com/camille-s/camiller) package.

## Installation

You can install this package from
[GitHub](https://github.com/CT-Data-Haven/cwi) with:

``` r
# install.packages("devtools")
devtools::install_github("CT-Data-Haven/cwi")
```

## Dependencies

This package relies heavily on:

- The [`tidyverse`](http://tidyverse.org/) packages, namely `dplyr`,
  `tidyr`, `purrr`, `stringr`, `forcats`, and `ggplot2` (version \>=
  3.0.0) (so a lot the tidyverse)
- `rlang` and `tidyselect` for non-standard evaluation in many functions
- `tidycensus` for actually getting all the Census data
- `sf` isn’t required but it’s encouraged

## Data

`cwi` ships with several datasets and shapefiles. These include:

- Shapes (as `sf` objects) of towns, tracts, and city neighborhoods for
  New Haven, Hartford, Bridgeport, and Stamford
- Common ACS table numbers—hopefully decreases time spent prowling
  around [the Census Bureau site](https://data.census.gov)
- Definitions of neighborhoods by tract or block group, and of regions
  by town

## Sources

This package contains functions to make it easier and more reproducible
to fetch and analyze data from:

- [American Community
  Survey](https://www.census.gov/programs-surveys/acs/) (US Census
  Bureau)
- [Decennial
  Census](https://www.census.gov/programs-surveys/decennial-census.html)
  (US Census Bureau)
- [Quarterly Workforce Indicators](https://lehd.ces.census.gov/) (US
  Census Bureau Center for Economic Studies)
- [Local Area Unemployment Statistics](https://www.bls.gov/lau/) (Bureau
  of Labor Statistics)
- [DataHaven’s Community Wellbeing
  Survey](https://ctdatahaven.org/reports/datahaven-community-wellbeing-survey)

## Example

Here’s an example of getting a big table to calculate homeownership
rates across many geographies at once:

``` r
library(dplyr)
library(cwi)
```

``` r
tenure <- multi_geo_acs(
  table = basic_table_nums$tenure,
  year = 2020,
  regions = regions[c("Greater New Haven", "New Haven Inner Ring", "New Haven Outer Ring")],
  counties = "New Haven",
  towns = regions[["Greater New Haven"]],
  us = TRUE
)
#> 
#> ── Table B25003: TENURE, 2020 ──────────────────────────────────────────────────
#> • Towns: Bethany, Branford, East Haven, Guilford, Hamden, Madison, Milford, New
#> Haven, North Branford, North Haven, Orange, West Haven, Woodbridge
#> • Regions: Greater New Haven, New Haven Inner Ring, New Haven Outer Ring
#> • Counties: New Haven County
#> • State: 09
#> • US: Yes
tenure
#> # A tibble: 57 × 9
#>     year level    state       county geoid name         variable estimate    moe
#>    <dbl> <fct>    <chr>       <chr>  <chr> <chr>        <chr>       <dbl>  <dbl>
#>  1  2020 1_us     <NA>        <NA>   1     United Stat… B25003_…   1.22e8 211970
#>  2  2020 1_us     <NA>        <NA>   1     United Stat… B25003_…   7.88e7 342600
#>  3  2020 1_us     <NA>        <NA>   1     United Stat… B25003_…   4.36e7 134985
#>  4  2020 2_state  <NA>        <NA>   09    Connecticut  B25003_…   1.39e6   3268
#>  5  2020 2_state  <NA>        <NA>   09    Connecticut  B25003_…   9.15e5   5015
#>  6  2020 2_state  <NA>        <NA>   09    Connecticut  B25003_…   4.70e5   4548
#>  7  2020 3_county Connecticut <NA>   09009 New Haven C… B25003_…   3.33e5   1647
#>  8  2020 3_county Connecticut <NA>   09009 New Haven C… B25003_…   2.07e5   2123
#>  9  2020 3_county Connecticut <NA>   09009 New Haven C… B25003_…   1.26e5   2225
#> 10  2020 4_region Connecticut <NA>   <NA>  Greater New… B25003_…   1.76e5   1834
#> # ℹ 47 more rows
```

``` r
homeownership <- tenure |>
  label_acs(year = 2020) |>
  dplyr::group_by(level, name) |>
  camiller::calc_shares(group = label, denom = "Total") |>
  dplyr::filter(stringr::str_detect(label, "Owner")) |>
  dplyr::select(level, name, share)

homeownership
#> # A tibble: 19 × 3
#> # Groups:   level, name [19]
#>    level    name                 share
#>    <fct>    <chr>                <dbl>
#>  1 1_us     United States        0.644
#>  2 2_state  Connecticut          0.661
#>  3 3_county New Haven County     0.621
#>  4 4_region Greater New Haven    0.596
#>  5 4_region New Haven Inner Ring 0.612
#>  6 4_region New Haven Outer Ring 0.793
#>  7 5_town   Bethany              0.917
#>  8 5_town   Branford             0.655
#>  9 5_town   East Haven           0.742
#> 10 5_town   Guilford             0.86 
#> 11 5_town   Hamden               0.637
#> 12 5_town   Madison              0.862
#> 13 5_town   Milford              0.745
#> 14 5_town   New Haven            0.28 
#> 15 5_town   North Branford       0.86 
#> 16 5_town   North Haven          0.826
#> 17 5_town   Orange               0.905
#> 18 5_town   West Haven           0.514
#> 19 5_town   Woodbridge           0.893
```

``` r
geo_level_plot(homeownership, value = share, hilite = "#EA7FA2", 
               title = "Homeownership in Greater New Haven, 2020")
```

<img src="man/figures/README-geo_plot-1.png" width="100%" />

See more detail in the vignette: `vignette("basic-workflow")`.
