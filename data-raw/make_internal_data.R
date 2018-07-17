# sysdata.rda except all in one use_data call
# so this sources the files that create them, then writes use_data(internal = T)
source("./data-raw/make_laus_codes.R", local = T)
source("./data-raw/make_acs_vars.R", local = T)
usethis::use_data(laus_measures, decennial_nums, internal = TRUE, overwrite = TRUE)
