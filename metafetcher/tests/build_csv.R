source("R/db_ctx.R")
source("R/utils.R")
source('R/discover.R')


fn_dbids <- '../tmp/tests/dbs.RDS'
fn_prog <- '../tmp/tests/resolve_i.RDS'

get_ids <- function (N) {
  ns <- N / 15

  if (!file.exists(fn_dbids)) {
    db_ids <- readRDS(fn_dbids)

    return(db_ids)
  }

  lim <- round(runif(1, 2000, 35000))
  records <- db.query(sprintf("SELECT chebi_id FROM chebi_data LIMIT %s OFFSET %s", lim, ns*3))
  db_ids <- records[[db_tag]]

  lim <- round(runif(1, 2000, 35000))
  records <- db.query(sprintf("SELECT pubchem_id FROM chebi_data LIMIT %s OFFSET %s", lim, ns))
  db_ids <- c(db_ids, records[[db_tag]])

  lim <- round(runif(1, 2000, 35000))
  records <- db.query(sprintf("SELECT kegg_id FROM chebi_data LIMIT %s OFFSET %s", lim, ns))
  db_ids <- c(db_ids, records[[db_tag]])


  lim <- round(runif(1, 2000, 35000))
  records <- db.query(sprintf("SELECT hmdb_id FROM hmdb_data LIMIT %s OFFSET %s", lim, ns*3))
  db_ids <- c(db_ids, records[[db_tag]])

  lim <- round(runif(1, 2000, 35000))
  records <- db.query(sprintf("SELECT pubchem_id FROM hmdb_data LIMIT %s OFFSET %s", lim, ns))
  db_ids <- c(db_ids, records[[db_tag]])

  lim <- round(runif(1, 2000, 35000))
  records <- db.query(sprintf("SELECT kegg_id FROM hmdb_data LIMIT %s OFFSET %s", lim, ns))
  db_ids <- c(db_ids, records[[db_tag]])


  lim <- round(runif(1, 2000, 35000))
  records <- db.query(sprintf("SELECT lipidmaps_id FROM lipidmaps_data LIMIT %s OFFSET %s", lim, ns*3))
  db_ids <- c(db_ids, records[[db_tag]])

  lim <- round(runif(1, 2000, 35000))
  records <- db.query(sprintf("SELECT pubchem_id FROM lipidmaps_data LIMIT %s OFFSET %s", lim, ns))
  db_ids <- c(db_ids, records[[db_tag]])

  lim <- round(runif(1, 2000, 35000))
  records <- db.query(sprintf("SELECT kegg_id FROM lipidmaps_data LIMIT %s OFFSET %s", lim, ns))
  db_ids <- c(db_ids, records[[db_tag]])

  # save
  db_ids <- get_ids(7500)
  saveRDS(db_ids, fn_dbids)

  return(db_ids)
}

get_last_progress <- function () {
  if (!file.exists(fn_prog)) {
    last_i <- 0
    saveRDS(last_i, fn_prog)
  } else {
    # iteration tracker
    last_i <- readRDS(fn_prog)
  }

  return(last_i)
}

save_progress <- function (i) {
  saveRDS(i, fn_prog)
}

build_csv <- function () {
  db_ids <- get_ids(7500)
  i <- get_last_progress()
  N <- 20
  L <- nrow(db_ids)

  resolve.options$suppress <<- TRUE
  resolve.options$open_connection <<- FALSE

  db.connect()

  start_time <- Sys.time()
  print(sprintf("Parsing %s records. Started at %s", L, start_time))

  while (i < L) {
    # pump 10 entries and resolve
    df.res[db_tag] <- db_ids[i:(i+N-1)]

    result <- resolve(df.res)
    df.out <- revert_df(result$df)

    write.table(df.out, "../tmp/tests/resolve_dump.csv", row.names = FALSE, col.names=FALSE, append = T, sep="|")

    i <- i + N
    print(sprintf("%s/%s...", i, L))
    save_progress(i)
  }

  db.disconnect()
}


build_csv()
