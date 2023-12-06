# sysdata.rda except all in one use_data call
# so this sources the files that create them, then writes use_data(internal = T)
source("./data-raw/make_laus_codes.R", local = TRUE)
source("./data-raw/make_lehd.R", local = TRUE)
# source("./data-raw/make_census_vars.R", local = TRUE)
usethis::use_data(laus_measures, qwi_avail, internal = TRUE, overwrite = TRUE)
