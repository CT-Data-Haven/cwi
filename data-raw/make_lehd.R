# WRITE: occ_codes
# READ: data-raw/files/occ_codes.xlsx

# INDUSTRY CODES -- NAICS
naics_codes <- readr::read_csv("https://lehd.ces.census.gov/data/schema/latest/label_industry.csv", col_types = "ccc") |>
  dplyr::filter(industry == "00" | ind_level == "2")

usethis::use_data(naics_codes, overwrite = TRUE)


# QWI AVAILABILITY -- YEARS AVAILABLE BY STATE
qwi_avail <- rvest::read_html("https://ledextract.ces.census.gov/loading_status.html") |>
  rvest::html_table() |>
  `[[`(1) |>
  janitor::clean_names() |>
  dplyr::mutate(dplyr::across(start_quarter:end_quarter, ~as.numeric(stringr::str_extract(., "\\d{4}")))) |>
  dplyr::inner_join(dplyr::distinct(tidycensus::fips_codes, state, state_code), by = "state") |>
  dplyr::select(state_code, start_year = start_quarter, end_year = end_quarter)

# make internal
# usethis::use_data(qwi_avail, overwrite = TRUE)


# OCCUPATION CODES -- OCC (CENSUS) & SOC (BLS)
# keep most groups top-level except management etc (first category)
occ_fn <- file.path("data-raw", "files", "occ_codes.xlsx")
if (!file.exists(occ_fn)) {
  download.file(url = "https://www2.census.gov/programs-surveys/demo/guidance/industry-occupation/2018-ACS-PUMS-and-2018-SIPP-Public-Use-Occupation-Code-List.xlsx",
                destfile = occ_fn)
}
top_occ <- readxl::read_excel(occ_fn, sheet = 1, range = "C4:C8", col_names = "description") |>
  tidyr::extract(description, into = c("occ_code", "description"), regex = "(\\d{4}\\s\\-\\s\\d{4})\\s+([\\w\\s[:punct:]]+)$") |>
  dplyr::mutate(occ_code = gsub("\\s", "", occ_code)) |>
  dplyr::mutate(is_top = TRUE)

# headings list a range of codes in occ_codes
# don't otherwise get classified as major groups
# f'it, just doing this manually
occ_grps <- c("Management, Business, and Financial Occupations",
          "Computer, Engineering, and Science Occupations",
          "Education, Legal, Community Service, Arts, and Media Occupations",
          "Healthcare Practitioners and Technical Occupations",
          "Service Occupations",
          "Sales and Office Occupations",
          "Natural Resources, Construction, and Maintenance Occupations",
          "Production, Transportation, and Material Moving Occupations",
          "Military Specific Occupations")
occ <- readxl::read_excel(occ_fn, sheet = 1, skip = 10, col_names = c("occ_code", "soc_code", "description")) |>
  dplyr::filter(!grepl("Combines", soc_code),
                !is.na(soc_code),
                !is.na(occ_code)) |>
  dplyr::mutate(description = stringr::str_squish(description)) |>
  dplyr::mutate(description = gsub("\\:$", "", description)) |>
  dplyr::mutate(is_hdr = grepl("\\-", occ_code))

occ_codes <- occ |>
  dplyr::left_join(top_occ, by = c("occ_code", "description")) |>
  dplyr::filter(is_hdr) |>
  dplyr::mutate(is_major_grp = tidyr::replace_na((is_top | description %in% occ_grps), FALSE)) |>
  dplyr::mutate(occ_group = ifelse(is_major_grp, description, NA_character_)) |>
  tidyr::fill(occ_group, .direction = "down") |>
  dplyr::select(is_major_grp, occ_group, occ_code, soc_code, description) |>
  dplyr::filter(description != "Management, Business, Science, and Arts Occupations") # this is really broad--want to separate these out

usethis::use_data(occ_codes, overwrite = TRUE)


