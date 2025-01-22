#' Quickly make a `ggplot` to view data by geographic level
#'
#' This is a quick way to make a bar chart, a Cleveland dotplot, or a histogram from a set of data, filled by geographic level.
#' @param data A data frame to use for plotting.
#' @param name Bare column name containing names, i.e. independent variable.
#' @param value Bare column name containing values, i.e. dependent variable.
#' @param level Bare column name containing geographic levels for fill.
#' @param type String: one of `"col"` (bar chart, using [ggplot2::geom_col()], `"point"` (dot plot, using [ggplot2::geom_point()]), or `"hist"` (histogram, using [ggplot2::geom_histogram()]); defaults `"col"`.
#' @param hilite String giving the highlight color, used for the lowest geography present.
#' @param title String giving the title, if desired, for the plot.
#' @param dark_gray String giving the named gray color for the highest geography; defaults `"gray20"`.
#' @param light_gray String giving the named gray color for the second lowest geography; defaults `"gray60"`.
#' @param ... Any additional parameters to pass to the underlying geom function.
#' @seealso [ggplot2::geom_col()] [ggplot2::geom_point()] [ggplot2::geom_histogram()]
#' @return A ggplot
#' @export
geo_level_plot <- function(data,
                           name = name,
                           value = value,
                           level = level,
                           type = c("col", "hist", "point"),
                           hilite = "dodgerblue",
                           title = NULL,
                           dark_gray = "gray20",
                           light_gray = "gray60",
                           ...) {
    # type can be column (col), histogram (hist), or point (point)
    type <- rlang::arg_match(type)
    if (!grepl("gr(a|e)y", dark_gray)) dark_gray <- "gray20"
    if (!grepl("gr(a|e)y", light_gray)) light_gray <- "gray60"

    geos <- sort(unique(data[[rlang::as_label(rlang::enquo(level))]]))

    g1 <- as.numeric(stringr::str_extract(dark_gray, "\\d+$"))
    g2 <- as.numeric(stringr::str_extract(light_gray, "\\d+$"))
    pal1 <- round(seq(g1, g2, length.out = length(geos) - 1))
    pal <- c(paste0("gray", pal1), hilite)

    data <- dplyr::ungroup(data)
    data <- dplyr::mutate(data, dplyr::across({{ name }}, ~ forcats::fct_reorder(.x, {{ value }})))

    p <- ggplot2::ggplot(data, ggplot2::aes(fill = {{ level }}))
    p <- p + ggplot2::scale_fill_manual(values = pal)
    p <- p + ggplot2::theme_minimal()

    if (type == "hist") {
        p <- p + ggplot2::geom_histogram(ggplot2::aes(x = {{ value }}), ...)
    } else if (type == "point") {
        p <- p + ggplot2::geom_point(ggplot2::aes(x = {{ name }}, y = {{ value }}), stroke = 0, size = 4, shape = 21, ...)
        p <- p + ggplot2::coord_flip()
    } else {
        p <- p + ggplot2::geom_col(ggplot2::aes(x = {{ name }}, y = {{ value }}), width = 0.8, ...)
        p <- p + ggplot2::coord_flip()
        p <- p + ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05)))
    }
    if (!is.null(title)) {
        p <- p + ggplot2::ggtitle(title)
    }
    p
}
