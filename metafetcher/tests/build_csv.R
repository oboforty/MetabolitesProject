source("R/db_ctx.R")
source("R/utils.R")
source('R/discover.R')


build_csv <- function (db) {
  db_tag <- paste(db,'_id',sep="")
  file_i <- '../tmp/tests/resolve_i.RDS'

  if (!file.exists(file_i)) {
    # reset csv file and iteration tracker
    df.res <- create_empty_record(0, attr.meta)
    write.table(df.res, "../tmp/tests/resolve_dump.csv", row.names = FALSE, col.names=TRUE, sep="|", quote=FALSE)

    last_i <- 0
    saveRDS(last_i, file_i)
    print("Resetting file")
  } else {
    # iteration tracker
    last_i <- readRDS(file_i)
    print(sprintf("Continuing at %s ...", last_i))
  }

  records <- db.query(sprintf("SELECT %s FROM %s_data LIMIT 10000 OFFSET %s", db_tag, db, last_i))
  db_ids <- records[[db_tag]]

  df.res <- create_empty_record(10, attr.meta)

  resolve.options$suppress <<- TRUE
  resolve.options$open_connection <<- FALSE

  start_time <- Sys.time()
  db.connect()

  i <- 1
  N <- 10
  L <- nrow(records)
  print(sprintf("Parsing %s records", L))

  while (i < L) {
    # pump 10 entries and resolve
    df.res[db_tag] <- db_ids[i:(i+N-1)]

    result <- resolve(df.res)

    df.out <- revert_df(result$df)

    write.table(df.out, "../tmp/tests/resolve_dump.csv", row.names = FALSE, col.names=FALSE, append = T, sep="|")

    i <- i + N
    last_i <- last_i + N
    print(sprintf("%s/%s...", i, L))
    saveRDS(last_i, file_i)
  }

  db.disconnect()
}

build_csv("chebi")
