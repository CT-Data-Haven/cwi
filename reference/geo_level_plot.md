# Quickly make a `ggplot` to view data by geographic level

This is a quick way to make a bar chart, a Cleveland dotplot, or a
histogram from a set of data, filled by geographic level.

## Usage

``` r
geo_level_plot(
  data,
  name = name,
  value = value,
  level = level,
  type = c("col", "hist", "point"),
  hilite = "dodgerblue",
  title = NULL,
  dark_gray = "gray20",
  light_gray = "gray60",
  ...
)
```

## Arguments

- data:

  A data frame to use for plotting.

- name:

  Bare column name containing names, i.e. independent variable.

- value:

  Bare column name containing values, i.e. dependent variable.

- level:

  Bare column name containing geographic levels for fill.

- type:

  String: one of `"col"` (bar chart, using
  [`ggplot2::geom_col()`](https://ggplot2.tidyverse.org/reference/geom_bar.html),
  `"point"` (dot plot, using
  [`ggplot2::geom_point()`](https://ggplot2.tidyverse.org/reference/geom_point.html)),
  or `"hist"` (histogram, using
  [`ggplot2::geom_histogram()`](https://ggplot2.tidyverse.org/reference/geom_histogram.html));
  defaults `"col"`.

- hilite:

  String giving the highlight color, used for the lowest geography
  present.

- title:

  String giving the title, if desired, for the plot.

- dark_gray:

  String giving the named gray color for the highest geography; defaults
  `"gray20"`.

- light_gray:

  String giving the named gray color for the second lowest geography;
  defaults `"gray60"`.

- ...:

  Any additional parameters to pass to the underlying geom function.

## Value

A ggplot

## See also

[`ggplot2::geom_col()`](https://ggplot2.tidyverse.org/reference/geom_bar.html)
[`ggplot2::geom_point()`](https://ggplot2.tidyverse.org/reference/geom_point.html)
[`ggplot2::geom_histogram()`](https://ggplot2.tidyverse.org/reference/geom_histogram.html)
