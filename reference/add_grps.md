# Collapse variable into groups and sum

This function makes it easy to collapse multiple labels of some column
into groups, then sum them. The advantage of using this over simply
relabeling a factor column (such as with
[`forcats::fct_collapse`](https://forcats.tidyverse.org/reference/fct_collapse.html))
is that categories here don't have to be mutually exclusive. For
example, from a table of populations by age group, you could collapse
and aggregate into total population, people 18+, and people 65+ all
within a single function call.

## Usage

``` r
add_grps(data, grp_list, group = group, value = estimate, moe = NULL)
```

## Arguments

- data:

  A data frame; will honor grouping

- grp_list:

  A named list of groups to collapse `group` into, either as characters
  that *exactly* match the labels in the grouping column, or as numbers
  giving the position of each label within unique values of the grouping
  column. Position numbers are easier to type correctly.

- group:

  Bare column name giving groups in data; will be converted to factor

- value:

  Bare column name of values. Defaults to `estimate`

- moe:

  Bare column name of margins of error; if supplied, MOEs of sums will
  be included in output

## Value

A data frame/tibble with sums of `estimate`. Retains grouping columns

## Details

The quickest and most fool-proof way to create aggregate groups is to
give their positions within a column's unique values. In this example
column of ages:

    1 ages 0-5
    2 ages 6-17
    3 ages 18-34
    4 ages 35-64
    5 ages 65-84
    6 ages 85+

you would calculate total population from positions 1-6, ages 18+ from
positions 3-6, and ages 65+ from positions 5-6.
[`show_uniq()`](https://CT-Data-Haven.github.io/cwi/reference/show_uniq.md)
is a helper function for finding these positions.

## See also

[`show_uniq()`](https://CT-Data-Haven.github.io/cwi/reference/show_uniq.md)

## Examples

``` r
# make a list of the positions of the groups you want to collapse
# e.g. education$edu_level[2:16] has the education levels that we consider
# less than high school
education |>
    dplyr::group_by(name) |>
    add_grps(
        list(
            ages25plus = 1,
            less_than_high_school = 2:16,
            high_school_plus = 17:25,
            bachelors_plus = 22:25
        ),
        group = edu_level, value = estimate
    )
#> # A tibble: 20 × 3
#> # Groups:   name [5]
#>    name       edu_level             estimate
#>    <chr>      <fct>                    <dbl>
#>  1 Bethany    ages25plus                3725
#>  2 Bethany    less_than_high_school      130
#>  3 Bethany    high_school_plus          3595
#>  4 Bethany    bachelors_plus            2193
#>  5 East Haven ages25plus               20768
#>  6 East Haven less_than_high_school     1724
#>  7 East Haven high_school_plus         19044
#>  8 East Haven bachelors_plus            5201
#>  9 Hamden     ages25plus               41017
#> 10 Hamden     less_than_high_school     2375
#> 11 Hamden     high_school_plus         38642
#> 12 Hamden     bachelors_plus           19132
#> 13 New Haven  ages25plus               84441
#> 14 New Haven  less_than_high_school    11853
#> 15 New Haven  high_school_plus         72588
#> 16 New Haven  bachelors_plus           31866
#> 17 West Haven ages25plus               35813
#> 18 West Haven less_than_high_school     4393
#> 19 West Haven high_school_plus         31420
#> 20 West Haven bachelors_plus           10399
```
