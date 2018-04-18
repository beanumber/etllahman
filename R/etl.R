#' etl_extract.etl_etllahman
#' @export
#'

etl_extract.etl_etllahman <- function(obj, ...) {
  url <- "http://seanlahman.com/files/database/lahman2016-sql.zip"
  etl::smart_download(obj, url)
  invisible(obj)
}


#' @rdname etl_extract.etl_etllahman
#' @export

etl_transform.etl_etllahman <- function(obj, ...) {
  unzip(zipfile = file.path(attr(obj, "raw"), "lahman2016-sql.zip"),
        exdir = attr(obj, "load"))
  invisible(obj)
}

#' @rdname etl_load.etl_etllahman
#' @export

etl_load.etl_etllahman <- function(obj, ...) {
  sql <- list.files(attr(obj, "load"), pattern = ".sql", full.names = TRUE) %>%
    utils::head(1)
#  etl::dbRunScript(conn = obj$con, script = sql)
  system(paste0("mysql < '", sql, "'"))
  invisible(obj)
}
