#' Quickly make a `ggplot` to view data by geographic level
#'
#' This is a quick way to make a bar chart, a Cleveland dotplot, or a histogram from a set of data, filled by geographic level.
#' @param data A data frame to use for plotting.
#' @param name Bare column name containing names, i.e. independent variable.
#' @param value Bare column name containing values, i.e. dependent variable.
#' @param level Bare column name containing geographic levels for fill.
#' @param type String: one of `"col"` (bar chart), `"point"` (dot plot), or `"hist"` (histogram); defaults `"col"`.
#' @param hilite String giving the highlight color, used for the lowest geography present.
#' @param min_gray String giving the named gray color for the highest geography; defaults `"gray20"`.
#' @param max_gray String giving the named gray color for the second lowest geography; defaults `"gray60"`
#' @param ... Any additional parameters to pass to the underlying geom function
#' @return A ggplot
#' @export
geo_level_plot <- function(data, name = name, value = value, level = level, type = "col", hilite = "dodgerblue", min_gray = "gray20", max_gray = "gray60", ...) {
  # type can be column (col), histogram (hist), or point (point)
  if (!type %in% c("col", "hist", "point")) stop("'type' must be one of col, hist, or point")
  if (!grepl("gr(a|e)y", min_gray)) min_gray <- "gray20"
  if (!grepl("gr(a|e)y", max_gray)) max_gray <- "gray60"

  value_var <- rlang::enquo(value)
  name_var <- rlang::enquo(name)
  level_var <- rlang::enquo(level)

  geos <- data %>% dplyr::pull(level) %>% unique() %>% sort()

  g1 <- stringr::str_extract(min_gray, "\\d+$") %>% as.numeric()
  g2 <- stringr::str_extract(max_gray, "\\d+$") %>% as.numeric()
  pal <- seq(g1, g2, length.out = length(geos) - 1) %>%
    floor() %>%
    paste0("gray", .) %>%
    c(., hilite)

  p <- data %>%
    dplyr::ungroup() %>%
    dplyr::mutate(!!rlang::quo_name(name_var) := as.factor(!!name_var) %>% forcats::fct_reorder(!!value_var)) %>%
    ggplot2::ggplot(ggplot2::aes(fill = !!level_var)) +
    ggplot2::scale_fill_manual(values = pal)

  if (type == "hist") {
    p_out <- p +
      ggplot2::geom_histogram(ggplot2::aes(x = !!value_var), ...)
  } else if (type == "point") {
    p_out <- p +
      ggplot2::geom_point(ggplot2::aes(x = !!name_var, y = !!value_var), stroke = 0, size = 4, shape = 21, ...) +
      ggplot2::coord_flip()
  } else {
    p_out <- p +
      ggplot2::geom_col(ggplot2::aes(x = !!name_var, y = !!value_var), width = 0.8, ...) +
      ggplot2::coord_flip()
  }
  p_out + ggplot2::theme_minimal()
}

