# Village to town lookup

A crosswalk of Connecticut's Census-designated places (CDP) to the towns
(county subdivisions) intersecting with them. With the 2010 boundaries,
places were generally each within a single town, but the 2020 boundaries
increased the number of places, including ones that span multiple towns.
This table now has weights to show how much of a place's population is
in the associated town. This version also includes all places, not just
ones that differ from the corresponding town. Note that places don't
span the full state. All populations are from the 2020 decennial census,
and overlaps are based on fitting blocks within places.

## Usage

``` r
village2town
```

## Format

A data frame with 224 rows and 7 variables:

- town:

  Town (county subdivision) name

- place:

  CDP name

- place_geoid:

  CDP FIPS code

- town_pop:

  Population of the full town

- place_pop:

  Population of the full CDP

- overlap_pop:

  Population of the overlapping area, interpolated from block
  populations

- place_wt:

  Share of CDP population included in the town-CDP overlapping area

## Source

Spatial overlay of TIGER shapefiles and populations from the 2020
Decennial Census DHC table P1.
