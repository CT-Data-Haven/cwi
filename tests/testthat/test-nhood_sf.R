# test that neighborhood boundaries line up with towns
# this would have prevented the error in the weights tables that incorrectly assigned outside tracts to some neighborhoods
test_that("neighborhood_shapes line up with town boundaries", {
    sf::sf_use_s2(FALSE)
    title_case <- function(x) {
        x <- stringr::str_replace_all(x, "_", " ")
        x <- stringr::str_to_title(x)
        x
    }
    # error if difference is more than 1.5 sqmi
    thresh <- 1.5
    cities <- tibble::lst(
        bridgeport_sf,
        hartford_sf,
        new_haven_sf,
        stamford_sf
    ) |>
        rlang::set_names(stringr::str_remove, "_sf$")
    diff_areas <- purrr::imap(cities, function(nb_sf, city) {
        if (!"town" %in% names(nb_sf)) {
            nb_sf$town <- title_case(city)
        }
        city_sf <- nb_sf |>
            # dplyr::mutate(town = dplyr::coalesce(town, city)) |>
            dplyr::group_by(town) |>
            dplyr::summarise()
        town_sf <- cwi::town_sf |>
            dplyr::filter(name %in% city_sf$town)
        sf::st_sym_difference(sf::st_union(city_sf), sf::st_union(town_sf)) |>
            sf::st_area() |>
            units::set_units("mi2") |>
            as.numeric()
    })
    purrr::map(diff_areas, \(x) expect_lt(x, thresh))
})
