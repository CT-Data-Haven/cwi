#' @title Easily add a logo to a ggplot
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function wraps around a few functions from `cowplot` and
#' `magick` to add a logo (or other annotation) to the bottom of a `ggplot` plot,
#' an otherwise tedious and easy to forget process. It's meant to be flexible in
#' the types of objects it can place; as a result, it's less flexible in their
#' placement and customization. For more specific needs, the source of this
#' function should be easy to build upon.
#' @param plot A `ggplot` object onto which the logo will be placed.
#' @param image Either a string giving the path or URL to an image file to be
#' read by `magick::image_read`; the results of reading a file or manipulating
#' an image already with `magick::image_read` or other `magick` functions;
#' a `ggplot` object / grob; some other object that can be handled by
#' `cowplot::draw_image`; or `NULL`, the default. If `NULL`, the image will
#' come from the file at `system.file("extdata/logo.svg", package = "cwi")`.
#' As built, this is a logo for DataHaven, but that file can be replaced for
#' repackaging this library for other organizations or projects.
#' @param position String, either "left" or "right", giving the side on which
#' the logo should be aligned. Default: "right"
#' @param height Numeric: the height of the logo, as a percentage of the height
#' of the image given in `plot`. Adjust as necessary based on the dimensions
#' of the logo. Default: 0.05
#' @param place_inside Logical: if `TRUE` (default), logo will be drawn within
#' the plotting area; otherwise, an additional grob is built below the plot,
#' meaning the logo could later be cropped away, which may be undesirable.
#' @param ... Additional arguments passed to `cowplot::draw_grob` if attaching
#' a grob, or to `cowplot::draw_image` otherwise.
#' @return A `ggplot` object.
#' @examples
#' if(interactive()){
#'   p <- ggplot2::ggplot(iris, ggplot2::aes(x = Sepal.Length)) +
#'      ggplot2::geom_density() +
#'        ggplot2::labs(title = "Test chart", caption = "Source: 2019 ACS 5-year estimates")
#'
#'      add_logo(p)
#'      add_logo(p, magick::image_read(system.file("extdata/25th_logo.png", package = "cwi")),
#'      height = 0.1)
#'
#'      # This example logo is not all that attractive, but shows how you might
#'      # attach a ggplot grob as a dynamically-created logo
#'      dummy_data <- data.frame(town = letters[1:4],
#'                               pop = c(21000, 40000, 81000, 36000))
#'
#'      gg_logo <- ggplot2::ggplot(dummy_data, ggplot2::aes(x = town, y = pop)) +
#'        ggplot2::geom_col(width = 0.8, fill = "skyblue") +
#'        ggplot2::annotate(geom = "text", label = "DataHaven", x = 0.6, y = 6e4, hjust = 0,
#'                          family = "mono", size = 5) +
#'        ggplot2::theme_void()
#'
#'      add_logo(p, gg_logo, width = 0.2, height = 0.1)
#'   }
#' @export
#' @rdname add_logo
#' @seealso [magick::image_read()], [cowplot::draw_image()]
add_logo <- function(plot, image = NULL, position = c("right", "left"), height = 0.05, place_inside = TRUE, ...) {
  m <- ggplot2::calc_element("plot.margin", plot$theme)
  if (!is.null(m)) {
    margin <- m
  } else {
    margin <- ggplot2::calc_element("plot.margin", ggplot2::theme_get())
  }

  position <- match.arg(position)
  if (position == "left") {
    halign <- 0
  } else {
    halign <- 1
  }
  p1 <- cowplot::ggdraw() +
    cowplot::draw_plot(plot + ggplot2::theme(plot.margin = ggplot2::margin(0, 0, 0, 0)))
  if (is.null(image)) {
    image <- magick::image_read(system.file("extdata/logo.svg", package = "cwi"))
  }

  # height is relative to canvas, so if outside main plot, set to take up whole height
  if (place_inside) {
    h_logo <- height
  } else {
    h_logo <- 1
  }

  if ("magick-image" %in% class(image)) {
    logo_grob <- cowplot::draw_image(image, x = 0, halign = halign, y = 0, valign = 0, height = h_logo, ...)
  } else if ("gg" %in% class(image)) {
    logo_grob <- cowplot::draw_grob(cowplot::as_grob(image), x = 0, halign = halign, y = 0, valign = 0, height = h_logo, ...)
  } else {
    logo_grob <- cowplot::draw_image(image, x = 0, halign = halign, y = 0, valign = 0, height = h_logo, ...)
  }

  if (place_inside) {
    out <- p1 + logo_grob
  } else {
    out <- cowplot::plot_grid(
      plot,
      cowplot::ggdraw() + logo_grob,
      ncol = 1, rel_heights = c(1, height)
    )
  }
  out +
    ggplot2::theme(plot.margin = margin)
}

