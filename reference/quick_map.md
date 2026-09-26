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

  `xlim,ylim`

  :   Limits for the x and y axes. These limits are specified in the
      units of the default CRS. By default, this means projected
      coordinates (`default_crs = NULL`). How limit specifications
      translate into the exact region shown on the plot can be confusing
      when non-linear or rotated coordinate systems are used as the
      default crs. First, different methods can be preferable under
      different conditions. See parameter `lims_method` for details.
      Second, specifying limits along only one direction can affect the
      automatically generated limits along the other direction.
      Therefore, it is best to always specify limits for both x and y.
      Third, specifying limits via position scales or `xlim()`/`ylim()`
      is strongly discouraged, as it can result in data points being
      dropped from the plot even though they would be visible in the
      final plot region.

  `expand`

  :   If `TRUE`, the default, adds a small expansion factor to the
      limits to ensure that data and axes don't overlap. If `FALSE`,
      limits are taken exactly from the data or `xlim`/`ylim`. Giving a
      logical vector will separately control the expansion for the four
      directions (top, left, bottom and right). The `expand` argument
      will be recycled to length 4 if necessary. Alternatively, can be a
      named logical vector to control a single direction, e.g.
      `expand = c(bottom = FALSE)`.

  `crs`

  :   The coordinate reference system (CRS) into which all data should
      be projected before plotting. If not specified, will use the CRS
      defined in the first sf layer of the plot.

  `default_crs`

  :   The default CRS to be used for non-sf layers (which don't carry
      any CRS information) and scale limits. The default value of `NULL`
      means that the setting for `crs` is used. This implies that all
      non-sf layers and scale limits are assumed to be specified in
      projected coordinates. A useful alternative setting is
      `default_crs = sf::st_crs(4326)`, which means x and y positions
      are interpreted as longitude and latitude, respectively, in the
      World Geodetic System 1984 (WGS84).

  `datum`

  :   CRS that provides datum to use when generating graticules.

  `label_graticule`

  :   Character vector indicating which graticule lines should be
      labeled where. Meridians run north-south, and the letters `"N"`
      and `"S"` indicate that they should be labeled on their north or
      south end points, respectively. Parallels run east-west, and the
      letters `"E"` and `"W"` indicate that they should be labeled on
      their east or west end points, respectively. Thus,
      `label_graticule = "SW"` would label meridians at their south end
      and parallels at their west end, whereas `label_graticule = "EW"`
      would label parallels at both ends and meridians not at all.
      Because meridians and parallels can in general intersect with any
      side of the plot panel, for any choice of `label_graticule` labels
      are not guaranteed to reside on only one particular side of the
      plot panel. Also, `label_graticule` can cause labeling artifacts,
      in particular if a graticule line coincides with the edge of the
      plot panel. In such circumstances, `label_axes` will generally
      yield better results and should be used instead.

      This parameter can be used alone or in combination with
      `label_axes`.

  `label_axes`

  :   Character vector or named list of character values specifying
      which graticule lines (meridians or parallels) should be labeled
      on which side of the plot. Meridians are indicated by `"E"` (for
      East) and parallels by `"N"` (for North). Default is `"--EN"`,
      which specifies (clockwise from the top) no labels on the top,
      none on the right, meridians on the bottom, and parallels on the
      left. Alternatively, this setting could have been specified with
      `list(bottom = "E", left = "N")`.

      This parameter can be used alone or in combination with
      `label_graticule`.

  `lims_method`

  :   Method specifying how scale limits are converted into limits on
      the plot region. Has no effect when `default_crs = NULL`. For a
      very non-linear CRS (e.g., a perspective centered around the North
      pole), the available methods yield widely differing results, and
      you may want to try various options. Methods currently implemented
      include `"cross"` (the default), `"box"`, `"orthogonal"`, and
      `"geometry_bbox"`. For method `"cross"`, limits along one
      direction (e.g., longitude) are applied at the midpoint of the
      other direction (e.g., latitude). This method avoids excessively
      large limits for rotated coordinate systems but means that
      sometimes limits need to be expanded a little further if extreme
      data points are to be included in the final plot region. By
      contrast, for method `"box"`, a box is generated out of the limits
      along both directions, and then limits in projected coordinates
      are chosen such that the entire box is visible. This method can
      yield plot regions that are too large. Finally, method
      `"orthogonal"` applies limits separately along each axis, and
      method `"geometry_bbox"` ignores all limit information except the
      bounding boxes of any objects in the `geometry` aesthetic.

  `ndiscr`

  :   Number of segments to use for discretising graticule lines; try
      increasing this number when graticules look incorrect.

  `default`

  :   Is this the default coordinate system? If `FALSE` (the default),
      then replacing this coordinate system with another one creates a
      message alerting the user that the coordinate system is being
      replaced. If `TRUE`, that warning is suppressed.

  `clip`

  :   Should drawing be clipped to the extent of the plot panel? A
      setting of `"on"` (the default) means yes, and a setting of
      `"off"` means no. In most cases, the default of `"on"` should not
      be changed, as setting `clip = "off"` can cause unexpected
      results. It allows drawing of data points anywhere on the plot,
      including in the plot margins. If limits are set via `xlim` and
      `ylim` and some data points fall outside those limits, then those
      data points may show up in places such as the axes, the legend,
      the plot title, or the plot margins.

  `reverse`

  :   A string giving which directions to reverse. `"none"` (default)
      keeps directions as is. `"x"` and `"y"` can be used to reverse
      their respective directions. `"xy"` can be used to reverse both
      directions.

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

  `parse`

  :   If `TRUE`, the labels will be parsed into expressions and
      displayed as described in
      [`?plotmath`](https://rdrr.io/r/grDevices/plotmath.html).

  `label.padding`

  :   Amount of padding around label. Defaults to 0.25 lines.

  `label.r`

  :   Radius of rounded corners. Defaults to 0.15 lines.

  `label.size`

  :   **\[deprecated\]** Replaced by the `linewidth` aesthetic. Size of
      label border, in mm.

  `border.colour,border.color`

  :   Colour of label border. When `NULL` (default), the `colour`
      aesthetic determines the colour of the label border.
      `border.color` is an alias for `border.colour`.

  `text.colour,text.color`

  :   Colour of the text. When `NULL` (default), the `colour` aesthetic
      determines the colour of the text. `text.color` is an alias for
      `text.colour`.

  `fun.geometry`

  :   A function that takes a `sfc` object and returns a `sfc_POINT`
      with the same length as the input. If `NULL`,
      `function(x) sf::st_point_on_surface(sf::st_zm(x))` will be used.
      Note that the function may warn about the incorrectness of the
      result if the data is not projected, but you can ignore this
      except when you really care about the exact locations.

  `check_overlap`

  :   If `TRUE`, text that overlaps previous text in the same layer will
      not be plotted. `check_overlap` happens at draw time and in the
      order of the data. Therefore data should be arranged by the label
      column before calling `geom_text()`. Note that this argument is
      not supported by `geom_label()`.

  `geom`

  :   The geometric object to use to display the data for this layer.
      When using a `stat_*()` function to construct a layer, the `geom`
      argument can be used to override the default coupling between
      stats and geoms. The `geom` argument accepts the following:

      - A `Geom` ggproto subclass, for example `GeomPoint`.

      - A string naming the geom. To give the geom as a string, strip
        the function name of the `geom_` prefix. For example, to use
        `geom_point()`, give the geom as `"point"`.

      - For more information and other ways to specify the geom, see the
        [layer
        geom](https://ggplot2.tidyverse.org/reference/layer_geoms.html)
        documentation.

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
