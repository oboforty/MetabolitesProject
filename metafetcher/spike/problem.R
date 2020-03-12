

drv <- dbDriver("PostgreSQL")
con <<- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")



a <- dbGetQuery(con, "SELECT chebi_id from chebi_data LIMIT 2")

