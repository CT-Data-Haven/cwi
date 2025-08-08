# WRITE: gnh_tenure education

devtools::load_all()
gnh_tenure <- multi_geo_acs(basic_table_nums$tenure,
    towns = regions$`Greater New Haven`,
    counties = NULL, regions = regions["Greater New Haven"], year = 2023, verbose = FALSE
) |>
    label_acs(year = 2023) |>
    dplyr::mutate(tenure = forcats::as_factor(label) |>
        forcats::fct_relabel(stringr::str_remove, "^\\w+\\!{2}") |>
        forcats::fct_relabel(stringr::str_replace_all, "\\s", "_") |>
        forcats::fct_relabel(tolower) |>
        forcats::fct_recode(total_hh = "total")) |>
    dplyr::group_by(level, name) |>
    dplyr::select(level, name, tenure, estimate) |>
    calc_shares(group = tenure, denom = "total_hh", digits = 2) |>
    dplyr::ungroup()

# moved over from camiller
education <- tidycensus::get_acs(
    geography = "county subdivision",
    table = "B15003",
    state = "09", county = "170",
    year = 2023
) |>
    town_names(name_col = NAME) |>
    label_acs(year = 2023) |>
    dplyr::select(name = NAME, label, estimate, moe) |>
    dplyr::filter(name %in% c("New Haven", "Hamden", "West Haven", "East Haven", "Bethany")) |>
    separate_acs(into = c("edu_level"), drop_total = TRUE) |>
    tidyr::replace_na(list(edu_level = "Total"))

usethis::use_data(gnh_tenure, overwrite = TRUE)
usethis::use_data(education, overwrite = TRUE)
