# cwi 0.4.3
* Import `camiller::calc_shares`
* Add sample data from the ACS: `gnh_tenure`

# cwi 0.4.2

Since the 2020 ACS is delayed, I decided we should still have copies of 2019 geography-related files. This should be temporary, but for now there are 2 versions of the tract shapefile (`tract_sf` and `tract_sf19`), and 2 versions of each neighborhood-tract weight table (e.g. `new_haven_tracts` and `new_haven_tracts19`, and so on). Once all the data is out, I'll remove the 2019 versions and bump up the package version.

# cwi 0.4.1

* Update `tract_sf` and `town_sf` to 2020 boundaries. Don't expect anything should have changed for towns, but many tracts were added after the Census Bureau released redistricting data.
* Handle typos in some crosstabs.

# cwi 0.4.0

* Rewrote neighborhood weights with the 2020 redistricting block boundaries. Dropped the block group table that was only done for New Haven, and changed the name of `nhv_tracts` to `new_haven_tracts` to match those for other cities.
* QWI API is working again, but payroll data is missing from their database.

# cwi 0.3.2

# cwi 0.3.1

* Minor behind-the-scenes updates

# cwi 0.3.0

* QWI example in the basic workflow vignette is currently turned off, because the Census QWI API has been down for at least a few days now. Will turn it back on when the API is (hopefully) back online.
* **New function:** Add a function `separate_acs` as a very lazy way to split ACS labels.

# cwi 0.2.0

* Added finished versions of `read_xtab`, `read_weights`, `xtab2df`, and `collapse_n_wt` for working with DataHaven Community Wellbeing Survey crosstabs—see vignettes 
* Added `add_logo` with built-in DataHaven logo
* Bug fixes in `sub_nonanswers`, `xwalk`

# cwi 0.1.3

# cwi 0.1.2

* `multi_geo_acs` & `multi_geo_decennial` call `janitor::clean_names` before returning. This keeps columns aligned properly if neighborhoods are included.

# cwi 0.1.1

* Expanded `xwalk` data to include more geographic levels.
* Minor vignette cleanup.

# cwi 0.1.0

* Added a `NEWS.md` file to track changes to the package.
* Functions that make use of API keys have explicit key arguments so Census and BLS API keys don't have to be stored in specific environment variables, though they'll still default to those same environment variables.
* Installation should be easier and have less overhead, because there are now fewer dependencies.
* Fixed bugs with BLS API in `adj_inflation`.
* Both `multi_geo_acs` and `multi_geo_decennial` can aggregate neighborhood data. There's an example in the workflow vignette.
* Should now be up to date with newer `dplyr` 1.0.0 & `tidyr` 1.0.0 functions. 
* **New functions:** `jenks`, `dh_scaffold`
