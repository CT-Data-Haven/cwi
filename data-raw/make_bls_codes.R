# area types to keep: state A, county F, cities 25k+ G, cities <25k H
# laus_codes <- readr::read_tsv("https://download.bls.gov/pub/time.series/la/la.area") |>
#   dplyr::filter(area_text == "Connecticut" | stringr::str_detect(area_text, "( CT|CT )")) |>
#   dplyr::filter(area_type_code %in% c("A", "F", "G", "H")) |>
#   dplyr::mutate(area = stringr::str_extract(area_text, "^([A-Z][a-z]+\\s?)+") |> stringr::str_trim()) |>
#   dplyr::select(type = area_type_code, area, code = area_code)

# bls updated the measures listed--for now, filter to the original 4

# no longer allows direct download--403 error
# got these headers from firefox devtools
headers <- list(
    "User-Agent" = "Mozilla/5.0 (X11; Linux x86_64; rv:135.0) Gecko/20100101 Firefox/135.0",
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
    "Accept-Language" = "en-US,en;q=0.5",
    "Accept-Encoding" = "gzip, deflate, br",
    "Connection" = "keep-alive"
)


base_url <- "https://download.bls.gov/pub/time.series"
paths <- list(
    laus_measures = c("la", "la.measure"),
    laus_codes = c("la", "la.area"),
    cpi_series = c("cu", "cu.series")
) |>
    purrr::map(\(x) file.path(base_url, paste(x, collapse = "/")))

get_bls <- function(path, hdrs) {
    h <- curl::new_handle()
    curl::handle_setheaders(h, .list = hdrs)
    curl::curl(path, open = "rb", handle = h)
}

fetch <- purrr::map(paths, get_bls, headers) |>
    purrr::map(readr::read_tsv)

# laus measures: employed, unemployed, etc
laus_measures <- dplyr::filter(fetch[["laus_measures"]], measure_code %in% c("03", "04", "05", "06"))

# laus codes: area names & codes
laus_codes <- fetch[["laus_codes"]] |>
    dplyr::mutate(state_code = substr(area_code, 3, 4)) |>
    dplyr::left_join(dplyr::distinct(tidycensus::fips_codes, state_code, state), by = "state_code") |>
    dplyr::filter(area_type_code %in% c("A", "F", "G", "H")) |>
    # dplyr::select(area_type_code, area_code, area_text, state_code) |>
    dplyr::mutate(area = trimws(stringr::str_extract(area_text, "(([A-Z][a-z\\-\\.]+\\s?)|of\\s?)+"))) |>
    dplyr::select(type = area_type_code, state_code, area, area_code)

# cpi series: seasonal, unseasonal, urban, etc
# all items = SA0
# keep alt bases, drop regions
cpi_series <- fetch[["cpi_series"]] |>
    dplyr::mutate(series_title = stringr::str_squish(series_title)) |>
    dplyr::filter(item_code %in% c("SA0", "AA0")) |>
    dplyr::filter(area_code == "0000") |>
    dplyr::mutate(
        seasonality = forcats::as_factor(seasonal) |>
            forcats::fct_recode(seasonal = "S", unseasonal = "U"),
        periodicity = forcats::as_factor(periodicity_code) |>
            forcats::fct_recode(monthly = "R", semiannual = "S"),
        base_type = forcats::as_factor(base_code) |>
            forcats::fct_recode(current = "S", alternative = "A")
    ) |>
    dplyr::select(id = series_id, seasonality, periodicity, base_type)

# usethis::use_data(laus_codes, overwrite = TRUE)
# usethis::use_data(cpi_series, overwrite = TRUE)
