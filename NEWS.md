# cwi v1.12.0 (2025-03-26)

## Feat

- first set of deprecating functions moving to dcws: `read_xtabs`, `read_weights`, `xtab2df`

## Fix

- second round of deprecations: `sub_nonanswers` and `collapse_n_wt`

# cwi v1.11.1 (2025-02-26)

## Fix

- **qwi_industry**: fix handling of QWI queries that return empty results

# cwi v1.11.0 (2025-02-19)

- Added `get_cpi` function, used under the hood of `adj_inflation`. Consider `adj_inflation` a higher-level application of `get_cpi`. The new function doesn't change a data frame, but it takes arguments for seasonality and period, allowing you to choose whether CPI values should be by month vs annual average, and whether they are seasonally adjusted. `adj_inflation` makes these decisions (annual averages not seasonally adjusted) for you for simplicity.

# cwi v1.10.0 (2025-01-29)

A small flurry of behind-the-scenes updates, including build tools and documentation.

# cwi v1.9.0 (2025-01-29)

- add memoized functions to keep availability lookups up to date, close #33 and #36

# cwi 1.8.0

* Fixed neighborhood shapefiles. These now come directly from cities' data portals in the [scratchpad repo](https://github.com/CT-Data-Haven/scratchpad), where they're published as a release, giving us a single source of truth for what those boundaries are. There were also errors where a few neighborhoods in Hartford / West Hartford and Stamford received tracts outside the city boundaries. As a result, weights tables have changed a fair amount. We'd also used our own combinations of Stamford neighborhoods but now have those from the city, with some shifts in what neighborhoods are lumped together and how they're labeled.

# cwi 1.7.1

* Updated and improved methods for making `zip2town` crosswalk, based on 2020 / 2022 geographies. The columns included in the data frame are slightly changed.
* Fixed issues with `qwi_industry`: the API now uses COGs for Connecticut instead of counties.

# cwi 1.7.0

Moved `add_logo` to the stylehaven package.

# cwi 1.6.3

Bumping package versions just to draw attention to the fact that there's now a set of PUMA proxy crosswalks; see `proxy_pumas`.

# cwi 1.6.2

Edit `xwalk`---there were still more FIPS codes to update with their COG-based versions. The data frame now includes COG-based codes for block groups, tracts, towns, and PUMAs.

# cwi 1.6.1

Bump ACS-related defaults to 2022

# cwi 1.6.0

**MINOR BREAKING CHANGE:** This update corresponds to the 2022 ACS data release, which is the first to use COGs instead of counties. Because COGs have different FIPS codes, town and tract FIPS codes (but apparently not block groups) have changed to match. The bulk of their code digits stay the same, but the portion signifying the county changed, e.g. 09**009**140101 is now 09**170**140101. To deal with that without breaking too much code, there are a few changes to the package:

- Neighborhood lookup tables (`bridgeport_tracts`, etc) have the previous county-based FIPS codes in the column `geoid`, and the new COG-based FIPS codes in the column `geoid_cog`.
- `xwalk` now has columns for COG-based town and tract FIPS codes, in addition to the previous county-based ones.
- Calling `multi_geo_acs` with `counties = "all"` (the default) will get you COGs, but `multi_geo_decennial` will get you counties, because the switch was not retroactive.
- The names of COGs returned by `multi_geo_acs` and used for names in the `regions` list are the ones the Census Bureau uses. Unfortunately, these aren't all the ones the state uses. For that, I've added a function `fix_cogs`, which replaces common names for them with the ones the state lists somewhat officially, e.g. Capitol COG is in the census data, Capitol Region COG is what the state usually uses but probably not always.
- Finally, the part that doesn't come up often but will break: previously the `multi_geo_*` functions took neighborhood names, weights, and GEOIDs as bare column names, with defaults (name, weight, and geoid, respectively). These now have to all be given as strings (i.e. in quotation marks), and geoid no longer has a default. This is to deal with the fact that some calculations will now need the neighborhood lookup tables' `geoid` columns, and some will need `geoid_cog`. This only matters when you're including neighborhoods in function calls.

# cwi 1.5.0

- The 2020 decennial census added a few dozen new census designated places, which is what `village2town` is based on. They now overlap with towns even less well than they used to. The table has been recalculated, with towns and villages joined based on overlapping population from the 2020 decennial, and now includes populations and weights in the crosswalk. 
That means things could break if you're expecting one set of CDPs and get another, or if you're not expecting new columns in that table. 

# cwi 1.4.0

- **MINOR BREAKING CHANGE:** `multi_geo_decennial` now defaults to 2020. Because the 2020 decennial uses a different summary file code from previous years, the default `sumfile` argument, if used with 2010, *will lead to an error.*
- 2020 decennial variables are now available in `decennial_vars20`. The 2010 ones are still in `decennial_vars10`.
- A new data frame, `cb_avail`, has the years, programs (ACS vs decennial), and dataset codes (SF1, ACS5, DHC, etc.) available from the Census Bureau's API.
- The function `dh_scaffold` was poorly named and not a great fit for the aims of this project. It's been moved to {stylehaven}; find it there as `scaffold_project`.
- Minor improvements to some warnings and other messages.

# cwi 1.3.0

- Add COGs to xwalk along with function for reconciling names 

# cwi 1.2.0

- Update defaults to 2021 where applicable: `multi_geo_acs`, `adj_inflation` base year, `label_acs`.
- Replace `acs_vars20` with `acs_vars21`.
- `multi_geo_decennial` now takes `"pl"` as a possible value for summary file, since the full 2020 Decennial data still aren't out.

# cwi 1.1.3

- Add regional councils of governments to `regions` list. Connecticut adopted these in 2022 to replace counties. Definitions from CTOPM [here](https://data.ct.gov/Government/Regional-Councils-of-Governments-Boundaries/idnf-uwvz).
- Add vignette on regions since there's so many of them now

# cwi 1.1.2

- Start handling updated MSA definitions—not sure that any datasets actually use these yet
- Add `rescale` option to `sub_nonanswers`—its default won't change any existing code

# cwi 1.1.1

**Bugfix:** occupational codes have larger groups and smaller groups. One larger group (Healthcare Practitioners and Technical Occupations) was mislabeled so it was marked as being under Education, Legal, Community Service, Arts, and Media Occupations.

# cwi 1.1.0

**Some updates to 2020**

- 2020 ACS 5-year data are finally out, so `acs_vars19` has been replaced by `acs_vars20`, and `multi_geo_acs` now uses 2020 as the default. Some examples & vignette code have been updated to match.
- Decennial census data _aren't_ out yet and won't be for some time, so decennial-related things still default to 2010.

# cwi 1.0.0

**Major exciting overhaul!** This was the first time I felt like enough of this package is flexible and well thought out to consider it a real release. A lot of the changes are under the hood--I split a lot of functions into slimmed-down main "caller" functions and multiple task-focused "helper" functions, making it easier to maintain the package, add or modify features, and use the same code for multiple tasks.

## User-facing updates

- Moved from base messages to `cli` for cleaner and clearer messaging (printouts on what fetch functions are getting, limitations to function calls, etc)
- Better handling of Census API calls to better deal with how very often their servers are busted
- Metadata: several behind-the-scenes datasets that set limits of functions' API calls are now expanded to not just be limited to Connecticut--includes `qwi_industry` and `laus_trend`.
- Added a table of occupation codes for main occupation groups
- Better documentation for many functions

## Breaking changes

- I've never liked the levels for the `multi_geo_*` functions--I don't really remember why I made these plural, but they're now singular. So a column that would have been e.g. "1_state", "2_counties", "3_towns" will now be "1_state", "2_county", "3_town". This might break filtering you've done by level.
- Renamed one function: `acs_quick_map` --> `quick_map`

## To do

- Update to 2020 ACS and Decennial defaults

# cwi 0.4.5

- Add sleep argument to `multi_geo_acs` for dealing with API crashes.

# cwi 0.4.4

- Add handling for reading crosstab weights placed in headers alongside data rather than in a separate table (e.g. for 2021).

# cwi 0.4.3

- Import `camiller::calc_shares`
- Add sample data from the ACS: `gnh_tenure`

# cwi 0.4.2

Since the 2020 ACS is delayed, I decided we should still have copies of 2019 geography-related files. This should be temporary, but for now there are 2 versions of the tract shapefile (`tract_sf` and `tract_sf19`), and 2 versions of each neighborhood-tract weight table (e.g. `new_haven_tracts` and `new_haven_tracts19`, and so on). Once all the data is out, I'll remove the 2019 versions and bump up the package version.

# cwi 0.4.1

- Update `tract_sf` and `town_sf` to 2020 boundaries. Don't expect anything should have changed for towns, but many tracts were added after the Census Bureau released redistricting data.
- Handle typos in some crosstabs.

# cwi 0.4.0

- Rewrote neighborhood weights with the 2020 redistricting block boundaries. Dropped the block group table that was only done for New Haven, and changed the name of `nhv_tracts` to `new_haven_tracts` to match those for other cities.
- QWI API is working again, but payroll data is missing from their database.

# cwi 0.3.2

# cwi 0.3.1

- Minor behind-the-scenes updates

# cwi 0.3.0

- QWI example in the basic workflow vignette is currently turned off, because the Census QWI API has been down for at least a few days now. Will turn it back on when the API is (hopefully) back online.
- **New function:** Add a function `separate_acs` as a very lazy way to split ACS labels.

# cwi 0.2.0

- Added finished versions of `read_xtab`, `read_weights`, `xtab2df`, and `collapse_n_wt` for working with DataHaven Community Wellbeing Survey crosstabs—see vignettes
- Added `add_logo` with built-in DataHaven logo
- Bug fixes in `sub_nonanswers`, `xwalk`

# cwi 0.1.3

# cwi 0.1.2

- `multi_geo_acs` & `multi_geo_decennial` call `janitor::clean_names` before returning. This keeps columns aligned properly if neighborhoods are included.

# cwi 0.1.1

- Expanded `xwalk` data to include more geographic levels.
- Minor vignette cleanup.

# cwi 0.1.0

- Added a `NEWS.md` file to track changes to the package.
- Functions that make use of API keys have explicit key arguments so Census and BLS API keys don't have to be stored in specific environment variables, though they'll still default to those same environment variables.
- Installation should be easier and have less overhead, because there are now fewer dependencies.
- Fixed bugs with BLS API in `adj_inflation`.
- Both `multi_geo_acs` and `multi_geo_decennial` can aggregate neighborhood data. There's an example in the workflow vignette.
- Should now be up to date with newer `dplyr` 1.0.0 & `tidyr` 1.0.0 functions.
- **New functions:** `jenks`, `dh_scaffold`
