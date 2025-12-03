# Package index

## Functions - fetching

Functions to fetch data from APIs

- [`laus_trend()`](https://CT-Data-Haven.github.io/cwi/reference/laus_trend.md)
  : Fetch local area unemployment statistics (LAUS) data over time
- [`multi_geo_acs()`](https://CT-Data-Haven.github.io/cwi/reference/multi_geo_acs.md)
  : Fetch an ACS table with multiple geography levels
- [`multi_geo_decennial()`](https://CT-Data-Haven.github.io/cwi/reference/multi_geo_decennial.md)
  : Fetch a decennial census table with multiple geography levels
- [`qwi_industry()`](https://CT-Data-Haven.github.io/cwi/reference/qwi_industry.md)
  : Get employment counts and total payroll over time

## Functions - analyzing and plotting

Functions to analyze or quickly plot data

- [`add_grps()`](https://CT-Data-Haven.github.io/cwi/reference/add_grps.md)
  : Collapse variable into groups and sum

- [`calc_shares()`](https://CT-Data-Haven.github.io/cwi/reference/calc_shares.md)
  : Make table of rates given a denominator

- [`adj_inflation()`](https://CT-Data-Haven.github.io/cwi/reference/inflation.md)
  [`get_cpi()`](https://CT-Data-Haven.github.io/cwi/reference/inflation.md)
  : Calculate inflation adjustments

- [`label_decennial()`](https://CT-Data-Haven.github.io/cwi/reference/label_census.md)
  [`label_acs()`](https://CT-Data-Haven.github.io/cwi/reference/label_census.md)
  : Quickly add the labels of census variables

- [`geo_level_plot()`](https://CT-Data-Haven.github.io/cwi/reference/geo_level_plot.md)
  :

  Quickly make a `ggplot` to view data by geographic level

- [`quick_map()`](https://CT-Data-Haven.github.io/cwi/reference/quick_map.md)
  : Quickly create a choropleth sketch

## Datasets - reference

Reference datasets, lookup tables, and crosswalks

- [`acs_vars`](https://CT-Data-Haven.github.io/cwi/reference/acs_vars.md)
  : Variable labels from the 2023 ACS
- [`ct5_clusters`](https://CT-Data-Haven.github.io/cwi/reference/ct5_clusters.md)
  : Five Connecticuts clusters
- [`decennial_vars`](https://CT-Data-Haven.github.io/cwi/reference/decennial_vars.md)
  [`decennial_vars10`](https://CT-Data-Haven.github.io/cwi/reference/decennial_vars.md)
  : Variable labels from the Decennial Census
- [`msa`](https://CT-Data-Haven.github.io/cwi/reference/msa.md) : Names
  and GEOIDs of regional MSAs
- [`naics_codes`](https://CT-Data-Haven.github.io/cwi/reference/naics_codes.md)
  : NAICS industry codes
- [`new_haven_tracts`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_tracts.md)
  [`bridgeport_tracts`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_tracts.md)
  [`stamford_tracts`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_tracts.md)
  [`hartford_tracts`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_tracts.md)
  [`new_haven_tracts19`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_tracts.md)
  [`bridgeport_tracts19`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_tracts.md)
  [`stamford_tracts19`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_tracts.md)
  [`hartford_tracts19`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_tracts.md)
  : City neighborhoods by tract
- [`occ_codes`](https://CT-Data-Haven.github.io/cwi/reference/occ_codes.md)
  : Census occupation codes
- [`proxy_pumas`](https://CT-Data-Haven.github.io/cwi/reference/proxy_pumas.md)
  : Proxy PUMAs
- [`regions`](https://CT-Data-Haven.github.io/cwi/reference/regions.md)
  : Regions of Connecticut
- [`school_dists`](https://CT-Data-Haven.github.io/cwi/reference/school_dists.md)
  : School districts by town
- [`basic_table_nums`](https://CT-Data-Haven.github.io/cwi/reference/table_nums.md)
  [`ext_table_nums`](https://CT-Data-Haven.github.io/cwi/reference/table_nums.md)
  : Common ACS table numbers
- [`village2town`](https://CT-Data-Haven.github.io/cwi/reference/village2town.md)
  : Village to town lookup
- [`xwalk`](https://CT-Data-Haven.github.io/cwi/reference/xwalk.md)
  [`tract2town`](https://CT-Data-Haven.github.io/cwi/reference/xwalk.md)
  : CT crosswalk
- [`zip2town`](https://CT-Data-Haven.github.io/cwi/reference/zip2town.md)
  : Zip to town lookup

## Datasets - examples

Datasets used for examples in vignettes, package docs, & testing

- [`education`](https://CT-Data-Haven.github.io/cwi/reference/education.md)
  : ACS demo data - educational attainment
- [`gnh_tenure`](https://CT-Data-Haven.github.io/cwi/reference/gnh_tenure.md)
  : ACS demo data - tenure

## Shapefiles

Shapefiles in `sf` format

- [`bridgeport_sf`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_shapes.md)
  [`hartford_sf`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_shapes.md)
  [`new_haven_sf`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_shapes.md)
  [`stamford_sf`](https://CT-Data-Haven.github.io/cwi/reference/neighborhood_shapes.md)
  : Neighborhood shapefiles of Connecticut cities
- [`town_sf`](https://CT-Data-Haven.github.io/cwi/reference/town_sf.md)
  : Connecticut town shapefile
- [`tract_sf`](https://CT-Data-Haven.github.io/cwi/reference/tract_sf.md)
  [`tract_sf19`](https://CT-Data-Haven.github.io/cwi/reference/tract_sf.md)
  : Connecticut tract shapefile

## Misc. / utilities

Miscellaneous functions

- [`check_cb_avail()`](https://CT-Data-Haven.github.io/cwi/reference/availability.md)
  [`check_qwi_avail()`](https://CT-Data-Haven.github.io/cwi/reference/availability.md)
  : Check availability of datasets
- [`batch_csv_dump()`](https://CT-Data-Haven.github.io/cwi/reference/batch_csv_dump.md)
  : Write a list of data frames to CSV and keep it movin'
- [`fix_cogs()`](https://CT-Data-Haven.github.io/cwi/reference/fix_cogs.md)
  : Fix names of COGs
- [`jenks()`](https://CT-Data-Haven.github.io/cwi/reference/jenks.md) :
  Quickly cut a vector with the Jenks/Fisher algorithms
- [`separate_acs()`](https://CT-Data-Haven.github.io/cwi/reference/separate_acs.md)
  : Separate labels given to ACS data
- [`show_uniq()`](https://CT-Data-Haven.github.io/cwi/reference/show_uniq.md)
  : Print unique values from a data frame column, then keep it moving
- [`town_names()`](https://CT-Data-Haven.github.io/cwi/reference/town_names.md)
  : Clean up town names as returned from ACS
