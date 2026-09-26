# internal--source in make_internal_data.R
# mini version of check_cb_avail
get_latest_endyears <- function() {
    programs <- c("acs", "dec")
    fetch <- jsonlite::read_json("https://api.census.gov/data.json")[[
        "dataset"
    ]]
    fetch <- purrr::map(fetch, function(x) {
        list(
            vintage = x$c_vintage,
            dataset = list(x$c_dataset),
            title = x$title
        )
    })
    fetch <- purrr::compact(fetch)
    fetch <- dplyr::bind_rows(fetch)
    fetch <- tidyr::unnest_wider(
        fetch,
        dataset,
        names_sep = "",
        names_repair = "unique"
    )
    fetch <- fetch[is.na(fetch$dataset3), ]
    fetch <- dplyr::select(
        fetch,
        vintage,
        program = dataset1,
        survey = dataset2,
        title
    )
    fetch <- dplyr::filter(fetch, program %in% c("acs", "dec"))
    fetch <- dplyr::group_by(fetch, program)
    fetch <- dplyr::slice_max(fetch, vintage)
    fetch <- dplyr::select(fetch, program, vintage)
    fetch <- dplyr::mutate(
        fetch,
        program = ifelse(program == "dec", "decennial", program)
    )
    fetch <- tibble::deframe(unique(fetch))
    fetch <- as.list(fetch)
    fetch
}

endyears <- get_latest_endyears()
