require("RPostgreSQL")

db_conn <- NULL


db.connect <- function () {
  print("Opening DB connection...")
  # connect to DB
  drv <- dbDriver("PostgreSQL")
  db_conn <<- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")

  return (db_conn)
}

db.query <- function (SQL) {
  if (is.null(db_conn)) {
    db.connect()
  }

  df <- dbGetQuery(db_conn, SQL)
  return(df)
}


db.disconnect <- function () {
  print("Closing DB connection...")

  dbDisconnect(db_conn)
  db_conn <-- NULL
}

db.transaction <- function () {
  dbBegin(db_conn)
}

db.commit <- function () {
  dbCommit(db_conn)
}

db.rollback <- function () {
  dbRollback(db_conn)
}

db.write_df <- function (table, df) {
  dbWriteTable(db_conn, table, value = df, append = TRUE, row.names = FALSE)
}
