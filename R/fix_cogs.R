#' @title Fix names of COGs
#' @description As Connecticut rolls out its use of COGs in place of counties,
#' the names of COGs might differ depending on who you ask (the Census Bureau,
#' CTOPM, or the COGs themselves). The crosswalk in `cwi::xwalk` uses the names
#' as they come from the Census; this function then renames them to match the
#' COGs' apparent preferences.
#' @param x A vector of names, either as a character or a factor.
#' @return A vector of the same length and type as input
#' @examples
#' fix_cogs(names(regions[1:6]))
#' @export
#' @seealso xwalk regions
fix_cogs <- function(x) {
    # should be either character or factor
    ref <- list(
        "Capitol Region COG" = c("Capitol", "Capitol Region"),
        "Connecticut Metro COG" = c("Connecticut Metro", "Greater Bridgeport"), # can't replace Greater Bridgeport since that might legit be used
        "Lower Connecticut River Valley COG" = c("Lower Connecticut River Valley"),
        "Naugatuck Valley COG" = c("Naugatuck Valley"),
        "Northeastern Connecticut COG" = c("Northeastern", "Northeastern Connecticut"),
        "Northwest Hills COG" = c("Northwest Hills"),
        "South Central Regional COG" = c("South Central", "South Central Regional", "South Central Connecticut"),
        "Southeastern Connecticut COG" = c("Southeastern Connecticut", "Southeastern"),
        "Western Connecticut COG" = c("Western Connecticut", "Western")
    )
    ref <- purrr::map(ref, function(x) c(x, paste(x, "COG")))
    ref <- tibble::enframe(ref, name = "good", value = "bad")
    ref <- tidyr::unnest(ref, bad)

    fx_cgs <- function(a) {
        dplyr::if_else(a %in% ref[["bad"]],
            ref[["good"]][match(a, ref[["bad"]])],
            a
        )
    }
    if (inherits(x, "character")) {
        fx_cgs(x)
    } else if (inherits(x, "factor")) {
        x <- forcats::fct_relabel(x, fx_cgs)
    } else {
        cli::cli_abort("{.arg x} should be either a character or factor.")
    }
}
