#' @title dh_scaffold
#' @description Setup directories for a typical DataHaven project
#' @param dir String: path to directory in which new files will be written. Default: '.'
#' @param input_data Create a directory `input_data`. Default: TRUE.
#'
#'  Standard use: data from some outside source to be analyzed in this project.
#' @param output_data Create a directory `output_data`. Default: TRUE.
#'
#'  Standard use: data written after analysis done in this project, generally in formats that can still be used for analysis and visualization (csv, rds) rather than formats for distribution (I usually add a folder `to_distro`) or to pass on to a client (xlsx). Nice spreadsheet outputs should go in `format_tables` or some other distribution-centered folder.
#' @param fetch_data Create a directory `fetch_data`. Default: TRUE.
#'
#' Standard use: a place to dump data as it comes in from API calls, queries, batch file downloads, etc.
#' @param analysis Create a directory `analysis`. Default: TRUE
#'
#' Standard use: main analysis scripts, both notebooks and .R scripts.
#' @param prep_scripts Create a directory `prep_scripts`. Default: FALSE
#'
#' Standard use: scripts use to prep or reshape data or documents, e.g. creating formatted spreadsheets for a client, making metadata, prepping to post to data.world, formatting for a website, bulk rendering parameterized Rmarkdown documents.
#' @param plots Create a directory `plots`. Default: FALSE
#'
#' Standard use: plots, either for in-house use or outside distribution.
#' @param format_tables Create a directory `format_tables`. Default: FALSE
#'
#' Standard use: spreadsheets--probably written by a script in `prep_scripts`--to be shared with clients or collaborators. Think of these as being files appropriate for presentation or addenda to a report, not for doing further analysis.
#' @param drafts Create a directory `drafts`. Default: FALSE
#'
#' Standard use: separating the more EDA-centered notebooks from notebooks used for drafting writing. Also a good place to keep files that have been edited in outside software (.docx, etc).
#' @param utils Create a directory `utils`. Default: TRUE
#'
#' Standard use: utility scripts and miscellaneous files, e.g. logo images, snippets of data, lists of colors to use.
#' @param addl A string vector of any additional directories to create. Default: NULL
#' @param gitblank Logical: whether to write a blank placeholder file in each new directory to force git tracking, even without yet having folder contents. Default: TRUE. If FALSE, empty directories will *not* be tracked by git.
#' @return Returns nothing, but prints paths to newly created directories.
#' @details This sets up a typical project directory structure that we use for many projects at DataHaven. It will write directories at the specified path, but it will NOT overwrite any directories that already exist. You'll have the option to cancel before anything is written.
#' @export
#' @rdname dh_scaffold
dh_scaffold <- function(dir = ".",
                        input_data = TRUE,
                        output_data = TRUE,
                        fetch_data = TRUE,
                        analysis = TRUE,
                        prep_scripts = FALSE,
                        plots = FALSE,
                        format_tables = FALSE,
                        drafts = FALSE,
                        utils = TRUE,
                        addl = NULL,
                        gitblank = TRUE) {
  # all_dirs <- purrr::set_names(c("input_data", "output_data", "fetch_data", "analysis", "prep_scripts", "plots", "format_tables", "drafts", "_utils"), stringr::str_remove, "^_")
  all_dirs <- tibble::lst(input_data, output_data, fetch_data, analysis, prep_scripts, plots, format_tables, drafts, utils)
  dirs <- purrr::set_names(c(names(all_dirs[unlist(all_dirs)]), purrr::compact(addl)))
  if (utils) names(dirs)[names(dirs) == "utils"] <- "_utils"
  does_dir_exist <- dirs %>%
    purrr::map_chr(~file.path(dir, .)) %>%
    purrr::map_lgl(dir.exists)

  # don't overwrite
  message("The following directories already exist and will NOT be overwritten:")
  cat(paste("*", dirs[does_dir_exist]), sep = "\n")
  cat("\n")

  # check that okay to write new dirs
  message("The following new directories will be created:")
  cat(paste("*", dirs[!does_dir_exist]), sep = "\n")
  cat("\n")

  message("Okay to proceed?")
  ok <- menu(c("Yes, write directories", "No, cancel"))

  if (ok == 1) {
    purrr::walk(dirs[!does_dir_exist], function(d) {
      path <- file.path(dir, d)
      dir.create(path)
      message(sprintf("Writing %s", path))
      if (gitblank) {
        g_path <- file.path(path, ".gitblank")
        file.create(g_path)
      }
    })
  } else {
    message("Aborting; nothing new will be written.")
  }
}
