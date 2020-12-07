#' Write a list of data frames to CSV and keep it movin'
#'
#' This function takes either a list of data frames, or a data frame and a column to split by, and writes them all to CSV files. It then returns the list of data frames, optionally row-binded back together. It fits neatly in the middle of a longer piped workflow.
#' @param .data A data frame or a list of data frames
#' @param split_by Bare column name of variable to split by. If `data` is a list, this is unnecessary and will be ignored.
#' @param path String giving a path at which to save files; defaults to current working directory.
#' @param base_name Optional string to be prepended to all file names.
#' @param bind Logical: whether to row-bind list of data frames into a single data frame. Defaults `FALSE`, in which case a list of data frames is returned.
#' @param verbose Logical: whether to print files' paths and names as they're written. Defaults `TRUE`.
#' @return Either a list of data frames (in case of `bind = FALSE`) or a single data frame (in case of `bind = TRUE`).
#'
#' @importFrom utils write.csv
#' @export
batch_csv_dump <- function(.data, split_by, path = ".", base_name = NULL, bind = FALSE, verbose = TRUE) {
  # if data is a data frame, split it. Otherwise treat as list
 if (is.data.frame(.data) & missing(split_by)) {
    stop("Please supply either a list of data frames, or a column to split data by.")
  }
  if (is.data.frame(.data)) {
    split_var <- rlang::enquo(split_by)
    data_list <- split(.data, dplyr::select(.data, !!split_var))
  } else {
    data_list <- .data
  }

  if (!file.exists(path)) {
    warning("Path ", path, " does not exist. Defaulting to current working directory.")
    path <- "."
  }

  out <- data_list %>%
    purrr::iwalk(function(df, name) {
      filename <- paste(c(base_name, name), collapse = "_") %>%
        stringr::str_replace_all("\\s+", "_") %>%
        paste0(".csv")
      filepath <- file.path(path, filename)
      write.csv(df, file = filepath, row.names = FALSE)

      if (verbose) message("Writing ", filepath)
    })
  if (bind) {
    out <- dplyr::bind_rows(out)
  }
  out
}
