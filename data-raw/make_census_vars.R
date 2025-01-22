devtools::load_all()
# ACS: MOST RECENT VARIABLES
acs_vars22 <- clean_acs_vars(year = 2022, survey = "acs5")


# DECENNIAL: 2 MOST RECENT
decennial_vars10 <- clean_decennial_vars(year = 2010, sumfile = "sf1")
decennial_vars20 <- clean_decennial_vars(year = 2020, sumfile = "dhc")


# ALL TABLES AVAILABLE: VINTAGE + PROGRAM + SURVEY CODE
include_str <- c("Detailed Tables", "PL 94-171", "Summary File \\d(?! Demographic Profile)", "SF\\d", "Demographic and Housing Characteristics")
exclude_str <- c("Selected Population", "American Indian", "Island Areas", "AIAN")
include_patt <- sprintf("(%s)", paste(include_str, collapse = "|"))
exclude_patt <- sprintf("(%s)", paste(exclude_str, collapse = "|"))

cb_avail <- jsonlite::read_json("https://api.census.gov/data.json")[["dataset"]]
cb_avail <- purrr::map(cb_avail, \(x) x[c("c_vintage", "c_dataset", "title")])
cb_avail <- purrr::map(cb_avail, purrr::compact)
cb_avail <- purrr::keep(cb_avail, \(x) grepl(include_patt, x$title, perl = TRUE) & !grepl(exclude_patt, x$title, perl = TRUE))
cb_avail <- purrr::map(cb_avail, purrr::modify_at, "c_dataset", \(x) rlang::set_names(x, c("program", "survey")))
cb_avail <- purrr::map_dfr(cb_avail, \(x) tibble::tibble(vintage = x$c_vintage, dataset = list(x$c_dataset), title = x$title))
cb_avail <- tidyr::unnest_wider(cb_avail, dataset)
cb_avail$title <- stringr::str_remove_all(cb_avail$title, "(Census: |Estimates: | \\d\\-Year$)")
cb_avail$title <- stringr::str_replace_all(cb_avail$title, c("Summary File " = "SF", "American Community Survey:" = "ACS"))
cb_avail <- dplyr::arrange(cb_avail, program, vintage, survey)


usethis::use_data(acs_vars22, overwrite = TRUE)
usethis::use_data(decennial_vars10, overwrite = TRUE)
usethis::use_data(decennial_vars20, overwrite = TRUE)
usethis::use_data(cb_avail, overwrite = TRUE)
