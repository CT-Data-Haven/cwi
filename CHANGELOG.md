## v2.0.4 (2026-05-15)

### Fix

- **census**: more fixes of census api key requirements
- **census**: add query param to availability checker now that census api requires key for all calls

## v2.0.3 (2025-12-09)

### Fix

- **data**: update school districts

## v2.0.2 (2025-12-03)

### Fix

- **data**: add COGs as regions in proxy_pumas

## v2.0.1 (2025-08-07)

### Fix

- remove extra dcws utility function

## v2.0.0 (2025-08-07)

### Feat

- move functions from camiller into cwi
- **deprecation**: remove dcws-related functions that were deprecated
- **data**: add educational attainment dataset for examples and testing

## v1.13.1 (2025-05-20)

### Fix

- **proxy_pumas**: rename Greater Bridgeport COG to Greater Bridgeport (same geo, more consistent name)

## v1.13.0 (2025-05-19)

### Feat

- copy over `calc_shares` function from camiller package

### Fix

- remove cws_demo dataset

## v1.12.2 (2025-03-27)

### Fix

- clean up old dependencies & vignettes

### Refactor

- **clean_names**: port and simplify janitor::clean_names to drop dependency

## v1.12.0 (2025-03-26)

### Feat

- first set of deprecating functions moving to dcws: `read_xtabs`, `read_weights`, `xtab2df`

### Fix

- second round of deprecations: `sub_nonanswers` and `collapse_n_wt`

## v1.11.1 (2025-02-26)

### Feat

- Add get_cpi function, better BLS handling

### Fix

- **qwi_industry**: fix handling of QWI queries that return empty results

## v1.10.0 (2025-01-29)

## v1.9.0 (2025-01-29)

### Feat

- add memoized functions to keep availability lookups up to date, close #33 and #36

## v1.8.0 (2025-01-22)

## v1.6.2 (2023-12-12)

## v1.4.0 (2023-08-25)

## v1.0.0 (2022-04-01)

## v0.4.4 (2022-01-20)

## v0.4.0 (2021-11-05)

## v0.3.1 (2021-07-30)

## v0.2.0 (2021-06-09)
