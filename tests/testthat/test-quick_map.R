test_that("quick_map successful calls return ggplots", {
    set.seed(123)
    town_df <- dplyr::tibble(name = regions[["Greater New Haven"]]) |>
        dplyr::mutate(value = stats::runif(13))
    # new haven neighborhoods
    hood_df <- new_haven_tracts |>
        dplyr::distinct(name) |>
        dplyr::slice(1:10) |>
        dplyr::mutate(value = stats::runif(10))
    # new haven tracts
    tract_df <- new_haven_tracts |>
        dplyr::distinct(geoid) |>
        dplyr::slice(1:10) |>
        dplyr::mutate(value = stats::runif(10))

    # each successfully return ggplot
    expect_s3_class(quick_map(town_df), "gg")
    expect_s3_class(quick_map(hood_df, level = "neighborhood", city = "New Haven"), "gg")
    expect_s3_class(quick_map(tract_df, name = geoid, level = "tract"), "gg")
})

test_that("quick_map catches invalid geo levels", {
    set.seed(123)
    hood_df <- new_haven_tracts19 |>
        dplyr::distinct(name) |>
        dplyr::slice(1:10) |>
        dplyr::mutate(value = stats::runif(10))

    # handle invalid level
    expect_error(quick_map(hood_df, level = "nhood", city = "New Haven"))
})

test_that("quick_map matches neighborhoods and city names", {
    set.seed(123)
    hood_df <- new_haven_tracts19 |>
        dplyr::distinct(name) |>
        dplyr::slice(1:10) |>
        dplyr::mutate(value = stats::runif(10))

    # if level = neighborhood, must supply city
    expect_error(quick_map(hood_df, level = "neighborhood", city = NULL))

    # using a city name that doesn't have shapefile associated
    expect_error(quick_map(hood_df, level = "neighborhood", city = "Hamden"), "hamden_sf")

    # using a shapefile that doesn't match data—only match is Downtown
    expect_error(quick_map(hood_df, level = "neighborhood", city = "Bridgeport"), "is nearly empty")
    # using a shapefile with no matches—filter out Downtown
    expect_error(quick_map(hood_df |>
        dplyr::filter(name != "Downtown"), level = "neighborhood", city = "Bridgeport"), "is empty")
})
