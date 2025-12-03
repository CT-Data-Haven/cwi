# Variable labels from the Decennial Census

Dataset of Decennial Census variable labels, loaded from
[`tidycensus::load_variables()`](https://walker-data.com/tidycensus/reference/load_variables.html)
and cleaned up slightly. 2010 and 2020 versions are saved separately and
have different variable code formats. `decennial_vars` has an attribute
`year` giving the year of the dataset.

## Usage

``` r
decennial_vars

decennial_vars10
```

## Format

A data frame with 8959 rows (2010) or 9067 rows (2020) and 3 variables:

- name:

  Variable code containing the table number and variable number

- label:

  Readable label of each variable

- concept:

  Table name

## Source

US Census Bureau via `tidycensus`

## Examples

``` r
# get the year
attr(decennial_vars, "year")
#> [1] 2020
```
