# Connecticut tract shapefile

Data frame of Connecticut tracts with `sf` geometries. `tract_sf19` is
the 2019 version, should you need an older shapefile.

## Usage

``` r
tract_sf

tract_sf19
```

## Format

Data frame of class `sf`.

- name:

  Tract FIPS code

- geometry:

  Tract geometry as `sfc_MULTIPOLYGON`

An object of class `sf` (inherits from `data.frame`) with 829 rows and 2
columns.
