# CT crosswalk

A crosswalk between geographies in Connecticut, built off of TIGER
shapefiles. `tract2town` is a subset with just tracts and towns. Tracts
that span multiple towns are deduplicated and listed with the town with
the largest areal overlap.

A version of `cwi::xwalk` that only contains tracts and town names, and
is deduplicated for tracts that span multiple towns.

## Usage

``` r
xwalk

tract2town
```

## Format

### For `xwalk`:

A data frame with 48358 rows and 17 variables:

- block:

  Block FIPS code

- block_grp:

  Block group FIPS code, based on county FIPS

- block_grp_cog:

  Block group FIPS code, based on COG FIPS as of 2022 ACS

- tract:

  Tract FIPS code, based on county FIPS

- tract_cog:

  Tract FIPS code, based on COG FIPS as of 2022 ACS

- town:

  Town name

- town_fips:

  Town FIPS code, based on county FIPS

- town_fips_cog:

  Town FIPS code, based on COG FIPS as of 2022 ACS

- county:

  County name

- county_fips:

  County FIPS code

- cog:

  COG name

- cog_fips:

  COG FIPS code

- msa:

  Metro/micropolitan area name

- msa_fips:

  Metro/micropolitan area FIPS code

- puma:

  PUMA name

- puma_fips:

  PUMA FIPS code, based on county FIPS

- puma_fips_cog:

  PUMA FIPS code, based on COG FIPS as of 2022 ACS

### For `tract2town`:

A data frame with 879 rows and 3 variables:

- tract:

  Tract FIPS code

- tract_cog:

  Tract FIPS code, based on COG FIPS as of 2022 ACS

- town:

  Town name

## Source

2020 and 2022 (for COGs & towns) TIGER shapefiles
