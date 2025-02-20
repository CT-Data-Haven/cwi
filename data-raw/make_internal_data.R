# sysdata.rda except all in one use_data call
# so this sources the files that create them, then writes use_data(internal = T)
source("./data-raw/make_bls_codes.R", local = TRUE)
# source("./data-raw/make_lehd.R", local = TRUE)
source("./data-raw/make_endyears.R", local = TRUE)
# source("./data-raw/make_census_vars.R", local = TRUE)
usethis::use_data(
  laus_measures,
  laus_codes,
  cpi_series,
  endyears,
  internal = TRUE, overwrite = TRUE)
