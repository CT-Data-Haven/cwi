# Separate labels given to ACS data

This is a quick wrapper around
[`tidyr::separate()`](https://tidyr.tidyverse.org/reference/separate.html)
written to match the standard formatting used for ACS variable labels.
These generally take the form e.g. "Total!!Male!!5 to 9 years". This
function will separate values by `"!!"` and optionally drop the
resulting "Total" column, which is generally constant for the entire
data frame.

## Usage

``` r
separate_acs(
  data,
  col = label,
  into = NULL,
  sep = "!!",
  drop_total = FALSE,
  ...
)
```

## Arguments

- data:

  A data frame such as returned by
  [`multi_geo_acs()`](https://CT-Data-Haven.github.io/cwi/reference/multi_geo_acs.md)
  or
  [`tidycensus::get_acs()`](https://walker-data.com/tidycensus/reference/get_acs.html).

- col:

  Bare column name where ACS labels are. Default: label

- into:

  Character vector of names of new variables. If `NULL` (the default),
  names will be assigned as "x1", "x2," etc. If you don't want to
  include the Total column, this character vector only needs to include
  the groups other than Total (see examples).

- sep:

  Character: separator between columns. Default: '!!'

- drop_total:

  Logical, whether to include the "Total" column that comes from
  separating ACS data. Default: FALSE

- ...:

  Arguments passed on to
  [`tidyr::separate`](https://tidyr.tidyverse.org/reference/separate.html)

  `remove`

  :   If `TRUE`, remove input column from output data frame.

  `convert`

  :   If `TRUE`, will run
      [`type.convert()`](https://rdrr.io/r/utils/type.convert.html) with
      `as.is = TRUE` on new columns. This is useful if the component
      columns are integer, numeric or logical.

      NB: this will cause string `"NA"`s to be converted to `NA`s.

  `extra`

  :   If `sep` is a character vector, this controls what happens when
      there are too many pieces. There are three valid options:

      - `"warn"` (the default): emit a warning and drop extra values.

      - `"drop"`: drop any extra values without a warning.

      - `"merge"`: only splits at most `length(into)` times

  `fill`

  :   If `sep` is a character vector, this controls what happens when
      there are not enough pieces. There are three valid options:

      - `"warn"` (the default): emit a warning and fill from the right

      - `"right"`: fill with missing values on the right

      - `"left"`: fill with missing values on the left

## Value

A data frame

## See also

[`tidyr::separate()`](https://tidyr.tidyverse.org/reference/separate.html)

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive()) {
    age <- label_acs(multi_geo_acs("B01001"))

    # Default: allow automatic labeling, in this case x1, x2, x3
    separate_acs(age)

    # Drop Total column, use automatic labeling (x1 & x2)
    separate_acs(age, drop_total = TRUE)

    # Keep Total column; assign names total, sex, age
    separate_acs(age, into = c("total", "sex", "age"))

    # Drop Total column; only need to name sex & age
    separate_acs(age, into = c("sex", "age"), drop_total = TRUE)

    # Carried over from tidyr::separate, using NA in place of the Total column
    # will also drop that column and yield the same as the previous example
    separate_acs(age, into = c(NA, "sex", "age"))
}
} # }
```
