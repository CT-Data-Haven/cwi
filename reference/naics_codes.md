# NAICS industry codes

A dataset of industry names with their NAICS codes. These are only the
main sectors, not detailed industry codes.

## Usage

``` r
naics_codes
```

## Format

A data frame with 21 rows and 3 variables:

- industry:

  NAICS code

- label:

  Industry name

- ind_level:

  Sector level: either "A" for all industries, or "2" for sectors

## Source

This is just a filtered version of file downloaded from
[LEHD](https://lehd.ces.census.gov/data/)
