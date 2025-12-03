# City neighborhoods by tract

Datasets of neighborhoods for New Haven, Hartford/West Hartford,
Stamford, and Bridgeport. Some tracts cross between more than one
neighborhood; use `weight` column for aggregating values such as
populations. Previously this included a block group version for New
Haven, which I've removed; I'm also renaming `nhv_tracts` to
`new_haven_tracts` for consistency.

## Usage

``` r
new_haven_tracts

bridgeport_tracts

stamford_tracts

hartford_tracts

new_haven_tracts19

bridgeport_tracts19

stamford_tracts19

hartford_tracts19
```

## Format

A data frame; the number of rows depends on the city.

- town:

  For `hartford_tracts`, the name of the town, because both Hartford and
  West Hartford neighborhoods are included; otherwise, no `town`
  variable is needed

- name:

  Neighborhood name

- geoid:

  11-digit FIPS code of the tract

- tract:

  6-digit FIPS code of the tract; same as geoid but missing state &
  county components.

- weight:

  Share of tract's households in that neighborhood

## Details

These were updated to 2020 tract definitions. There are still 2019
versions of weight tables with names ending in `"19"`; for the time
being, those will stick around for use with pre-2020 data.

Note also that there was an error in the tables for Stamford and
Hartford/West Hartford where a few neighborhoods were given extra tracts
from outside the town boundaries. This particularly would affect counts,
such as population totals by neighborhood, and was based on poor
alignment in doing spatial overlays. Fixed 5/22/2024.
