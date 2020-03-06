require("RPostgreSQL")

df <- readRDS("kegg.rds")
drv <- dbDriver("PostgreSQL")
db_conn <- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")


df$names <- df$names[[1]]

dbWriteTable(db_conn, "kegg_data", value = df, append = TRUE, row.names = FALSE)


dbDisconnect(db_conn)
