
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cwi <img src="man/figures/logo.png" align="right" />

[![Build
Status](https://travis-ci.org/CT-Data-Haven/cwi.svg?branch=master)](https://travis-ci.org/CT-Data-Haven/cwi)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/CT-Data-Haven/cwi?branch=master&svg=true)](https://ci.appveyor.com/project/CT-Data-Haven/cwi)

The goal of `cwi` is to get data, primarily the Census ACS, fetched,
aggregated, and analyzed for [DataHaven’s 2019 Community Index
reports](http://ctdatahaven.org/reports/greater-new-haven-community-index).
This includes functions to speed up and standardize analysis for
multiple staff people, preview trends and patterns we’ll need to write
about, and get data in more layperson-friendly formats.

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

  - The [`tidyverse`](http://tidyverse.org/) packages, namely
    `magrittr`, `dplyr`, `tidyr`, `purrr`, `stringr`, `forcats`, and
    `ggplot2` (version \>= 3.0.0) (so basically *all* the tidyverse)
  - `rlang` and `tidyselect` for non-standard evaluation in many
    functions
  - `tidycensus` for actually getting all the Census data
  - `sf` isn’t required but it’s encouraged

## Data

`cwi` ships with several datasets and shapefiles. These include:

  - Shapes (as `sf` objects) of towns, tracts, and city neighborhoods
    for New Haven, Hartford, Bridgeport, and Stamford
  - Common ACS table numbers—hopefully decreases time spent prowling
    around [FactFinder](https://factfinder.census.gov)
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
  - [Local Area Unemployment Statistics](https://www.bls.gov/lau/)
    (Bureau of Labor Statistics)

More to come (as of 7/17/2018) may include simplifications of working
with [LEHD Origin-Destination Employment
Statistics](https://lehd.ces.census.gov/data/) (LODES) and ACS public
use microdata samples (PUMS) via [IPUMS](https://usa.ipums.org/usa/).

## Example

Here’s an example of getting a big table to calculate homeownership
rates across many geographies at once:

``` r
library(dplyr)
library(stringr)
library(cwi)
```

``` r
tenure <- multi_geo_acs(
  table = basic_table_nums$tenure,
  year = 2018,
  regions = regions[c("Greater New Haven", "New Haven Inner Ring", "New Haven Outer Ring")],
  counties = "New Haven",
  towns = regions[["Greater New Haven"]],
  us = TRUE
)
#> Table B25003: TENURE
#> Geographies included:
#> Towns: Bethany, Branford, East Haven, Guilford, Hamden, Madison, Milford, New Haven, North Branford, North Haven, Orange, West Haven, Woodbridge
#> Regions: Greater New Haven, New Haven Inner Ring, New Haven Outer Ring
#> Counties: New Haven County
#> State: 09
#> US: Yes
tenure
#> # A tibble: 57 x 9
#>    GEOID NAME            variable   estimate    moe level     state county  year
#>    <chr> <chr>           <chr>         <dbl>  <dbl> <fct>     <chr> <chr>  <dbl>
#>  1 1     United States   B25003_001   1.20e8 232429 1_us      <NA>  <NA>    2018
#>  2 1     United States   B25003_002   7.64e7 367132 1_us      <NA>  <NA>    2018
#>  3 1     United States   B25003_003   4.33e7 139467 1_us      <NA>  <NA>    2018
#>  4 09    Connecticut     B25003_001   1.37e6   3671 2_state   <NA>  <NA>    2018
#>  5 09    Connecticut     B25003_002   9.07e5   4800 2_state   <NA>  <NA>    2018
#>  6 09    Connecticut     B25003_003   4.60e5   3488 2_state   <NA>  <NA>    2018
#>  7 09009 New Haven Coun… B25003_001   3.30e5   1775 3_counti… 09    <NA>    2018
#>  8 09009 New Haven Coun… B25003_002   2.04e5   1887 3_counti… 09    <NA>    2018
#>  9 09009 New Haven Coun… B25003_003   1.26e5   1974 3_counti… 09    <NA>    2018
#> 10 <NA>  Greater New Ha… B25003_001   1.77e5   1531 4_regions <NA>  <NA>    2018
#> # … with 47 more rows
```

``` r
homeownership <- tenure %>%
  label_acs() %>%
  group_by(level, NAME) %>%
  mutate(share = estimate / estimate[1]) %>% # or use camiller::calc_shares
  filter(str_detect(label, "Owner")) %>%
  select(level, name = NAME, share)

homeownership
#> # A tibble: 19 x 3
#> # Groups:   level, name [19]
#>    level      name                 share
#>    <fct>      <chr>                <dbl>
#>  1 1_us       United States        0.638
#>  2 2_state    Connecticut          0.663
#>  3 3_counties New Haven County     0.619
#>  4 4_regions  Greater New Haven    0.600
#>  5 4_regions  New Haven Inner Ring 0.621
#>  6 4_regions  New Haven Outer Ring 0.803
#>  7 5_towns    Bethany              0.915
#>  8 5_towns    Branford             0.702
#>  9 5_towns    East Haven           0.708
#> 10 5_towns    Guilford             0.862
#> 11 5_towns    Hamden               0.641
#> 12 5_towns    Madison              0.862
#> 13 5_towns    Milford              0.751
#> 14 5_towns    New Haven            0.276
#> 15 5_towns    North Branford       0.867
#> 16 5_towns    North Haven          0.834
#> 17 5_towns    Orange               0.883
#> 18 5_towns    West Haven           0.549
#> 19 5_towns    Woodbridge           0.890
```

``` r
geo_level_plot(homeownership, value = share, hilite = "#EA7FA2", 
               title = "Homeownership in Greater New Haven, 2018")
```

<img src="man/figures/README-geo_plot-1.png" width="100%" />

See more detail in the vignette: `vignette("basic-workflow")`.
