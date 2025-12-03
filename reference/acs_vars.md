# Variable labels from the 2023 ACS

Dataset of ACS variable labels, loaded from
[`tidycensus::load_variables()`](https://walker-data.com/tidycensus/reference/load_variables.html)
for 2023 and cleaned up slightly.

## Usage

``` r
acs_vars
```

## Format

A data frame with 28261 rows and 3 variables:

- name:

  Variable code, where first 6 characters are the table number and last
  3 digits are the variable number

- label:

  Readable label of each variable

- concept:

  Table name

## Source

US Census Bureau via `tidycensus`

## Details

This dataset is updated with each annual ACS release, with an attribute
`year` giving the ACS endyear of the dataset.

## Examples

``` r
# get the year
attr(acs_vars, "year")
#> [1] 2023
```
