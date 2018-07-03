#' Write a list of data frames to CSV and keep it movin'
#'
#' This function takes either a list of data frames, or a data frame and a column to split by, and writes them all to CSV files. It then returns the list of data frames, optionally row-binded back together. It fits neatly in the middle of a longer piped workflow.
#' @param data A data frame or a list of data frames
#' @param split_by Bare column name of variable to split by. If `data` is a list, this is unnecessary and will be ignored.
#' @param path String giving a path at which to save files; defaults to current working directory.
#' @param base_name Optional string to be prepended to all file names.
#' @param bind Logical: whether to row-bind list of data frames into a single data frame. Defaults `FALSE`, in which case a list of data frames is returned.
#' @return Either a list of data frames (in case of `bind = FALSE`) or a single data frame (in case of `bind = TRUE`).
#' @examples
#' \dontrun{
#'   race_pops %>%
#'     split(.$region) %>%
#'     batch_csv_dump(base_name = "race_pops", bind = TRUE) %>%
#'     dplyr::filter(variable != "total")
#' }
#' @export
batch_csv_dump <- function(data, split_by = NULL, path = ".", base_name = NULL, bind = FALSE) {
  # if data is a data frame, split it. Otherwise treat as list
  if (is.data.frame(data)) {
    if (is.null(split_by)) {
      stop("Please supply either a list of data frames, or a column to split data by.")
    } else {
      split_var <- rlang::enquo(split_by)
      data_list <- split(data, data %>% select(!!split_var))
    }
  } else {
    data_list <- data
  }

  if (!file.exists(path)) {
    warning("Path", path, "does not exist. Defaulting to current working directory.")
    path <- "."
  }

  out <- data_list %>%
    purrr::iwalk(function(df, name) {
      filename <- paste(base_name, name) %>%
        stringr::str_replace_all("\\s+", "_")
      filename <- paste0(filename, ".csv")
      readr::write_csv(df, path = paste(path, filename, sep = "/"))
    })
  if (bind) {
    out <- dplyr::bind_rows(out)
  }
  out
}
