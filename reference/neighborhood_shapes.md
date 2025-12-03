# Neighborhood shapefiles of Connecticut cities

Data frames of neighborhoods of Connecticut cities with `sf` geometries.
Includes Bridgeport, Hartford/West Hartford, New Haven, and Stamford.

## Usage

``` r
bridgeport_sf

hartford_sf

new_haven_sf

stamford_sf
```

## Format

Data frames (classes `data.frame` and `sf`). In each, `name` is the name
of each neighborhood, and `geometry` is the shape of each neighborhood
as either a `sfc_POLYGON` or `sfc_MULTIPOLYGON` object. `hartford_sf`
contains an additional variable, `town`, which marks the neighborhoods
as being in Hartford or West Hartford.

An object of class `sf` (inherits from `data.frame`) with 13 rows and 2
columns.

An object of class `sf` (inherits from `data.frame`) with 27 rows and 3
columns.

An object of class `sf` (inherits from `data.frame`) with 20 rows and 2
columns.

An object of class `sf` (inherits from `data.frame`) with 13 rows and 2
columns.

## Source

All neighborhood boundaries, with the exception of West Hartford, come
directly from their respective cities' online data portals. West
Hartford neighborhood boundaries are based directly on current tracts;
the common names corresponding to tracts were scraped from a third-party
real estate site.
