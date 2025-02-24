test_that("town_names removes 'town, * County'", {
    skip_on_ci()
    pops21 <- tidycensus::get_acs(
        geography = "county subdivision", variables = "B01003_001",
        state = "09", year = 2021,
        key = Sys.getenv("CENSUS_API_KEY")
    )
    clean21 <- town_names(pops21, NAME)

    pops22 <- tidycensus::get_acs(
        geography = "county subdivision", variables = "B01003_001",
        state = "09", year = 2022,
        key = Sys.getenv("CENSUS_API_KEY")
    )
    clean22 <- town_names(pops22, NAME)

    expect_false(any(grepl(" County, .+$", clean21$NAME)))
    expect_false(any(grepl(" Planning Region, .+$", clean22$NAME)))
})

test_that("town_names filters undefined", {
    skip_on_ci()
    pops21 <- tidycensus::get_acs(
        geography = "county subdivision", variables = "B01003_001",
        state = "09", county = "009", year = 2021,
        key = Sys.getenv("CENSUS_API_KEY")
    )
    clean21 <- town_names(pops21, NAME)
    # removes one observation of County subdivisions undefined
    expect_equal(nrow(clean21), nrow(pops21) - 1)
    # not all COGs have undefined but SCROG does, 170

    pops22 <- tidycensus::get_acs(
        geography = "county subdivision", variables = "B01003_001",
        state = "09", county = "170", year = 2022,
        key = Sys.getenv("CENSUS_API_KEY")
    )
    clean22 <- town_names(pops22, NAME)
    # removes one observation of County subdivisions undefined
    expect_equal(nrow(clean22), nrow(pops22) - 1)
})
