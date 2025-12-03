# Write a list of data frames to CSV and keep it movin'

This function takes either a list of data frames, or a data frame and a
column to split by, and writes them all to CSV files. It then returns
the list of data frames, optionally row-binded back together. It fits
neatly in the middle of a longer piped workflow.

## Usage

``` r
batch_csv_dump(
  data,
  split_by,
  path = ".",
  base_name = NULL,
  bind = FALSE,
  verbose = TRUE,
  ...
)
```

## Arguments

- data:

  A data frame or a list of data frames

- split_by:

  Bare column name of variable to split by. If `data` is a list, this is
  unnecessary and will be ignored.

- path:

  String giving a path at which to save files; defaults to current
  working directory.

- base_name:

  Optional string to be prepended to all file names.

- bind:

  Logical: whether to row-bind list of data frames into a single data
  frame. Defaults `FALSE`, in which case a list of data frames is
  returned.

- verbose:

  Logical: whether to print files' paths and names as they're written.
  Defaults `TRUE`.

- ...:

  Arguments passed on to
  [`utils::write.table`](https://rdrr.io/r/utils/write.table.html)

  `append`

  :   logical. Only relevant if `file` is a character string. If `TRUE`,
      the output is appended to the file. If `FALSE`, any existing file
      of the name is destroyed.

  `quote`

  :   a logical value (`TRUE` or `FALSE`) or a numeric vector. If
      `TRUE`, any character or factor columns will be surrounded by
      double quotes. If a numeric vector, its elements are taken as the
      indices of columns to quote. In both cases, row and column names
      are quoted if they are written. If `FALSE`, nothing is quoted.

  `eol`

  :   the character(s) to print at the end of each line (row). For
      example, `eol = "\r\n"` will produce Windows' line endings on a
      Unix-alike OS, and `eol = "\r"` will produce files as expected by
      Excel:mac 2004.

  `na`

  :   the string to use for missing values in the data.

  `dec`

  :   the string to use for decimal points in numeric or complex
      columns: must be a single character.

  `col.names`

  :   either a logical value indicating whether the column names of `x`
      are to be written along with `x`, or a character vector of column
      names to be written. See the section on ‘CSV files’ for the
      meaning of `col.names = NA`.

  `qmethod`

  :   a character string specifying how to deal with embedded double
      quote characters when quoting strings. Must be one of `"escape"`
      (default for `write.table`), in which case the quote character is
      escaped in C style by a backslash, or `"double"` (default for
      `write.csv` and `write.csv2`), in which case it is doubled. You
      can specify just the initial letter.

  `fileEncoding`

  :   character string: if non-empty declares the encoding to be used on
      a file (not a connection) so the character data can be re-encoded
      as they are written. See
      [`file`](https://rdrr.io/r/base/connections.html).

## Value

Either a list of data frames (in case of `bind = FALSE`) or a single
data frame (in case of `bind = TRUE`).
