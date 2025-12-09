#' Quickly create a choropleth sketch
#'
#' This is a quick way to create a choropleth sketch of town-, neighborhood-, or tract-level data. Uses a corresponding `sf` object; as of June 2018, this `sf` object must be one that ships with this package, or otherwise be globally available.
#'
#' @param data A data frame containing data by geography.
#' @param name Bare column name of location names to join; defaults `name`.
#' @param value Bare column name of numeric values to map; defaults `value`.
#' @param level String giving the desired geographic level; must be one of `"town"`, `"neighborhood"`, or `"tract"`. Defaults `"town"`.
#' @param city If geographic level is neighborhood, string of the corresponding city name to match to a spatial object.
#' @param n Number of breaks into which to bin values; defaults (approximately) 5.
#' @param palette String of a ColorBrewer palette; see [RColorBrewer::RColorBrewer()] for possible values. Defaults `"GnBu"`.
#' @param title String giving the title, if desired, for the plot.
#' @param ... Any other parameters to pass along to [ggplot2::geom_sf()], such as `color` or `size`.
#' @inheritDotParams ggplot2::geom_sf
#' @return A ggplot
#' @examples
#' \dontrun{
#' tidycensus::get_acs(
#'     geography = "county subdivision", year = 2023,
#'     variables = c(median_age = "B01002_001"), state = "09", county = "170"
#' ) |>
#'     town_names(NAME) |>
#'     dplyr::filter(NAME %in% regions$`Greater New Haven`) |>
#'     quick_map(name = NAME, value = estimate, title = "Median age by town, 2023", n = 6)
#' }
#' @seealso [ggplot2::geom_sf()]
#' @keywords quick-plotting-functions
#' @export
quick_map <- function(
    data,
    name = name,
    value = value,
    level = c("town", "neighborhood", "tract"),
    city = NULL,
    n = 5,
    palette = "GnBu",
    title = NULL,
    ...
) {
    # supply city if it's neighborhoods
    level <- rlang::arg_match(level)

    if (level == "neighborhood" & is.null(city)) {
        cli::cli_abort("If using neighborhoods, please supply a city name.")
    }

    name_lbl <- rlang::as_label(rlang::enquo(name))
    value_lbl <- rlang::as_label(rlang::enquo(value))

    if (level == "neighborhood") {
        shape_name <- sprintf(
            "%s_sf",
            tolower(stringr::str_replace_all(city, "\\s", "_"))
        )

        if (!exists(shape_name)) {
            cli::cli_abort(c(
                "{.var {shape_name}} wasn't found",
                "i" = "Your shapefile should either be part of this package or available in your working environment."
            ))
        }

        shape <- get(shape_name)
    } else if (level == "tract") {
        shape_name <- "tract_sf"
        shape <- cwi::tract_sf
    } else {
        shape_name <- "town_sf"
        shape <- cwi::town_sf
    }
    data <- dplyr::ungroup(data)
    data <- dplyr::mutate(data, dplyr::across({{ name }}, as.character))
    shape <- dplyr::mutate(shape, name = as.character(name))
    shape <- dplyr::inner_join(
        shape,
        data,
        by = stats::setNames(name_lbl, "name")
    )

    requested_locs <- dplyr::pull(data, {{ name }})
    matched_locs <- unique(shape[["name"]])
    unmatched_locs <- setdiff(requested_locs, matched_locs)
    if (length(matched_locs) < 2) {
        if (length(matched_locs) == 0) {
            cli::cli_abort(
                "After merging with your data, this sf object is empty. Are city and level set properly?"
            )
        } else {
            cli::cli_abort(
                "After merging with your data, this sf object is nearly empty. Are city and level set properly?"
            )
        }
    }
    # check for unmatched locations
    if (length(unmatched_locs) > 0) {
        cli::cli_alert_warning(
            "Some locations in your data weren't found in the shapefile {.var {shape_name}}: {.val {unmatched_locs}}"
        )
    }
    if (length(matched_locs) < n) {
        n <- ceiling(sqrt(length(matched_locs)))
        cli::cli_alert_info(
            "`n` is too large compared to the number of locations; setting `n` to {n} instead."
        )
    }

    # make shape$name, data$name_var characters if not already
    data_to_map <- dplyr::ungroup(shape)
    data_to_map$brk <- cwi::jenks(dplyr::pull(data_to_map, {{ value }}), n = n)
    p <- ggplot2::ggplot(data_to_map, ggplot2::aes(fill = brk))
    p <- p + ggplot2::geom_sf(...)
    p <- p + ggplot2::scale_fill_brewer(palette = palette, drop = FALSE)
    p <- p + ggplot2::theme_minimal()
    # p <- p + ggplot2::coord_sf(ndiscr = FALSE)
    p <- p + ggplot2::labs(fill = value_lbl)
    if (!is.null(title)) {
        p <- p + ggplot2::labs(title = title)
    }
    p
}
