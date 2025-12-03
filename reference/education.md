# ACS demo data - educational attainment

This is a table of educational attainment data for adults ages 25 and up
in a few New Haven-area towns obtained with
[`tidycensus::get_acs`](https://walker-data.com/tidycensus/reference/get_acs.html),
to be used in testing and examples.

## Usage

``` r
education
```

## Format

A data frame with 125 rows and 4 variables:

- name:

  Town name

- edu_level:

  Educational attainment

- estimate:

  Estimated count

- moe:

  Margin of error
