# Names and GEOIDs of regional MSAs

A reference dataset of all the metropolitan statistical areas (MSAs) in
the US, marked with whether they're in a New England state.

## Usage

``` r
msa
```

## Format

A data frame with 392 rows and 3 variables:

- geoid:

  GEOID/FIPS code

- name:

  Name of MSA

- region:

  String: whether MSA is inside or outside of New England

## Source

US Census Bureau via `tidycensus`. Note that these are as of 2020.
