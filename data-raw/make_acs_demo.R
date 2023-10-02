# WRITE: gnh_tenure

gnh_tenure <- multi_geo_acs(basic_table_nums$tenure, towns = regions$`Greater New Haven`,
              counties = NULL, regions = regions["Greater New Haven"], year = 2020, verbose = FALSE) |>
  label_acs(year = 2020) |>
  dplyr::mutate(tenure = forcats::as_factor(label) |>
                  forcats::fct_relabel(stringr::str_remove, "^\\w+\\!{2}") |>
                  forcats::fct_relabel(stringr::str_replace_all, "\\s", "_") |>
                  forcats::fct_relabel(tolower) |>
                  forcats::fct_recode(total_hh = "total")) |>
  dplyr::group_by(level, name) |>
  dplyr::select(level, name, tenure, estimate) |>
  calc_shares(group = tenure, denom = "total_hh", digits = 2) |>
  dplyr::ungroup()


usethis::use_data(gnh_tenure, overwrite = TRUE)
