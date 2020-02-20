




download <- function(db_tag) {
  # downloads whole database

  db <- get_db(db_tag)

  db$download_all()
}


