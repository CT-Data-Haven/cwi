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
