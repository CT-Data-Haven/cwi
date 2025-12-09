# WRITE: msa

ne <- c("CT", "MA", "ME", "NH", "RI", "VT")
ne_re <- sprintf("(%s)", paste(ne, collapse = "|"))
msa <- tigris::core_based_statistical_areas(year = 2020) |>
    sf::st_drop_geometry() |>
    cwi:::clean_names() |>
    dplyr::filter(lsad == "M1") |>
    dplyr::select(geoid, name) |>
    dplyr::mutate(
        region = ifelse(
            grepl(ne_re, name),
            "New England",
            "Outside New England"
        )
    ) |>
    dplyr::as_tibble()

usethis::use_data(msa, overwrite = TRUE)
