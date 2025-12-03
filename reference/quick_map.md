# Quickly create a choropleth sketch

This is a quick way to create a choropleth sketch of town-,
neighborhood-, or tract-level data. Uses a corresponding `sf` object; as
of June 2018, this `sf` object must be one that ships with this package,
or otherwise be globally available.

## Usage

``` r
quick_map(
  data,
  name = name,
  value = value,
  level = c("town", "neighborhood", "tract"),
  city = NULL,
  n = 5,
  palette = "GnBu",
  title = NULL,
  ...
)
```

## Arguments

- data:

  A data frame containing data by geography.

- name:

  Bare column name of location names to join; defaults `name`.

- value:

  Bare column name of numeric values to map; defaults `value`.

- level:

  String giving the desired geographic level; must be one of `"town"`,
  `"neighborhood"`, or `"tract"`. Defaults `"town"`.

- city:

  If geographic level is neighborhood, string of the corresponding city
  name to match to a spatial object.

- n:

  Number of breaks into which to bin values; defaults (approximately) 5.

- palette:

  String of a ColorBrewer palette; see
  [`RColorBrewer::RColorBrewer()`](https://rdrr.io/pkg/RColorBrewer/man/ColorBrewer.html)
  for possible values. Defaults `"GnBu"`.

- title:

  String giving the title, if desired, for the plot.

- ...:

  Arguments passed on to
  [`ggplot2::geom_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html)

  `mapping`

  :   Set of aesthetic mappings created by
      [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html). If
      specified and `inherit.aes = TRUE` (the default), it is combined
      with the default mapping at the top level of the plot. You must
      supply `mapping` if there is no plot mapping.

  `stat`

  :   The statistical transformation to use on the data for this layer.
      When using a `geom_*()` function to construct a layer, the `stat`
      argument can be used to override the default coupling between
      geoms and stats. The `stat` argument accepts the following:

      - A `Stat` ggproto subclass, for example `StatCount`.

      - A string naming the stat. To give the stat as a string, strip
        the function name of the `stat_` prefix. For example, to use
        `stat_count()`, give the stat as `"count"`.

      - For more information and other ways to specify the stat, see the
        [layer
        stat](https://ggplot2.tidyverse.org/reference/layer_stats.html)
        documentation.

  `position`

  :   A position adjustment to use on the data for this layer. This can
      be used in various ways, including to prevent overplotting and
      improving the display. The `position` argument accepts the
      following:

      - The result of calling a position function, such as
        `position_jitter()`. This method allows for passing extra
        arguments to the position.

      - A string naming the position adjustment. To give the position as
        a string, strip the function name of the `position_` prefix. For
        example, to use `position_jitter()`, give the position as
        `"jitter"`.

      - For more information and other ways to specify the position, see
        the [layer
        position](https://ggplot2.tidyverse.org/reference/layer_positions.html)
        documentation.

  `na.rm`

  :   If `FALSE`, the default, missing values are removed with a
      warning. If `TRUE`, missing values are silently removed.

  `show.legend`

  :   logical. Should this layer be included in the legends? `NA`, the
      default, includes if any aesthetics are mapped. `FALSE` never
      includes, and `TRUE` always includes.

      You can also set this to one of "polygon", "line", and "point" to
      override the default legend.

  `inherit.aes`

  :   If `FALSE`, overrides the default aesthetics, rather than
      combining with them. This is most useful for helper functions that
      define both data and aesthetics and shouldn't inherit behaviour
      from the default plot specification, e.g.
      [`annotation_borders()`](https://ggplot2.tidyverse.org/reference/annotation_borders.html).

## Value

A ggplot

## See also

[`ggplot2::geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)

## Examples

``` r
if (FALSE) { # \dontrun{
tidycensus::get_acs(
    geography = "county subdivision", year = 2023,
    variables = c(median_age = "B01002_001"), state = "09", county = "170"
) |>
    town_names(NAME) |>
    dplyr::filter(NAME %in% regions$`Greater New Haven`) |>
    quick_map(name = NAME, value = estimate, title = "Median age by town, 2023", n = 6)
} # }
```
