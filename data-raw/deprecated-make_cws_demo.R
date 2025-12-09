# WRITE: cws_demo
# READ: inst/extdata/test_xtab2015.xlsx

wts <- read_weights(system.file(
    "extdata/test_xtab2015.xlsx",
    package = "cwi"
)) |>
    dplyr::mutate(
        group = group |>
            stringr::str_replace("(?<=\\d) to (?=[\\$\\d])", "-") |>
            stringr::str_replace_all(",000", "K") |>
            stringr::str_replace("Less than (?=\\$)", "<") |>
            stringr::str_replace(" (or more|and older)", "+") |>
            stringr::str_replace("high school", "High School") |>
            stringr::str_remove(" degree") |>
            dplyr::recode(
                "High school or GED" = "High School",
                "African American/Black" = "Black/Afr Amer"
            )
    )

cws_demo <- dcws::read_xtabs(
    system.file("extdata/test_xtab2015.xlsx", package = "cwi"),
    year = 2015,
    process = TRUE
) |>
    dplyr::filter(code == "Q1") |>
    dplyr::left_join(wts, by = "group") |>
    tidyr::replace_na(list(weight = 1)) |>
    dplyr::mutate(dplyr::across(category:response, forcats::as_factor))

usethis::use_data(cws_demo, overwrite = TRUE)
