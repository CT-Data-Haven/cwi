# Clean up town names as returned from ACS

This function does two things: it removes text other than the town name
from the column given as `name_col`, and it removes any rows for "county
subdivisions not defined." For example, the string "Ansonia town, New
Haven County, Connecticut" will become "Ansonia."

## Usage

``` r
town_names(data, name_col)
```

## Arguments

- data:

  A data frame

- name_col:

  Bare column name of town names

## Value

A tibble/data frame with cleaned names and "not defined" towns removed

## Examples

``` r
pops <- tibble::tribble(
    ~name, ~total_pop,
    "County subdivisions not defined, New Haven County, Connecticut", 0,
    "Ansonia town, New Haven County, Connecticut", 18802,
    "Beacon Falls town, New Haven County, Connecticut", 6168,
    "Bethany town, New Haven County, Connecticut", 5513,
    "Branford town, New Haven County, Connecticut", 2802
)
town_names(pops, name_col = name)
#> # A tibble: 4 × 2
#>   name         total_pop
#>   <chr>            <dbl>
#> 1 Ansonia          18802
#> 2 Beacon Falls      6168
#> 3 Bethany           5513
#> 4 Branford          2802
```
