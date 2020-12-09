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
