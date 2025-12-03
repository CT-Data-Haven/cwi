# Zip to town lookup

A crosswalk of Connecticut's ZCTA5s and towns with shares of populations
and households in overlapping areas. Each row corresponds to a
combination of zip and town; therefore, some zips have more than one
observation, as do towns.

## Usage

``` r
zip2town
```

## Format

A data frame with 410 rows and 8 variables:

- town:

  Town name

- zip:

  5-digit zip code (ZCTA5)

- inter_pop:

  Population in this intersection of zips and towns

- inter_hh:

  Number of households in this intersection of zips and towns

- pct_of_town_pop:

  Percentage of the town's population that is also in this zip

- pct_of_town_hh:

  Percentage of the town's households that are also in this zip

- pct_of_zip_pop:

  Percentage of the zip's population that is also in this town

- pct_of_zip_hh:

  Percentage of the zip's households that are also in this town

## Source

Cleaned-up version of the Census [2022 ZCTA to county subdivision
relationship
file](https://www2.census.gov/geo/docs/maps-data/data/rel2022/acs22_cousub22_zcta520_st09.txt),
updated for Connecticut's 2022 revisions from counties to COGs.
