
library(etllahman)

db <- src_mysql_cnf(dbname = "lahman2016")
bdb <- etl("etllahman", db = db, dir = "~/dumps/lahman")

bdb %>%
  etl_init()

bdb %>%
  etl_update()
