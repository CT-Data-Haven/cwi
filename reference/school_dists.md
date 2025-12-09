# School districts by town

A crosswalk of Connecticut towns and school districts, including
regional districts. Some very small towns don't operate their own
schools and are not included here, whereas other towns are both part of
a regional district and operate some of their own schools, most commonly
their own elementary.

## Usage

``` r
school_dists
```

## Format

A data frame with 197 rows and 2 variables:

- district:

  School district name

- town:

  Name of town included in district

## Source

Distinct town-level district names come from the state's
[data.world](https://data.world/state-of-connecticut/9k2y-kqxn).
Regional districts and their towns come from EdSight.

## Details

Note that for aggregating by region, the Hartford-area regional district
CREC is not included here, because it spans so many other towns that
also run their own schools.CREC is of significant enough size that it
should generally be included in Greater Hartford aggregations or as its
own district for comparisons alongside e.g. Hartford and West Hartford.
