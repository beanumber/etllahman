#' etl_extract.etl_etllahman
#' ETL methods for accessing the Lahman Database
#' @inheritParams etl::etl_extract
#' @import etl
#' @export
#' @source \url{http://www.seanlahman.com/baseball-archive/statistics/}
#' @seealso \code{\link[etl]{etl_extract}}
#'

etl_extract.etl_etllahman <- function(obj, ...) {
  url <- "http://seanlahman.com/files/database/lahman2016-sql.zip"
  etl::smart_download(obj, url)
  invisible(obj)
}


#' @rdname etl_extract.etl_etllahman
#' @export

etl_transform.etl_etllahman <- function(obj, ...) {
  utils::unzip(zipfile = file.path(attr(obj, "raw"), "lahman2016-sql.zip"),
        exdir = attr(obj, "load"))
  invisible(obj)
}

#' @rdname etl_extract.etl_etllahman
#' @export
#' @importFrom magrittr %>%
#' @importFrom DBI dbExecute

etl_load.etl_etllahman <- function(obj, ...) {
  sql <- list.files(attr(obj, "load"), pattern = ".sql", full.names = TRUE) %>%
    utils::head(1)
#  etl::dbRunScript(conn = obj$con, script = sql)
  system(paste0("mysql < '", sql, "'"))

  # customizations
  etl::dbRunScript(conn = obj$con, system.file("sql", "customize.mysql", package = "etllahman"))
  DBI::dbExecute(obj$con, "
    UPDATE Teams SET SH = (
      SELECT sum(ifnull(sh,0)) FROM Batting
      WHERE yearid=Teams.yearid AND teamid=Teams.teamid AND lgid=Teams.lgid);")
  DBI::dbExecute(obj$con, "
    UPDATE Teams SET TPA = ab + bb + ifnull(hbp,0) + ifnull(sf,0) + ifnull(sh,0);")

  invisible(obj)
}
