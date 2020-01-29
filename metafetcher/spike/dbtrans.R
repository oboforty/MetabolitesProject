drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="postgres")
dbGetQuery(con, "select count(*) from sales")
dbBegin(con)
rs <- dbSendQuery(con,
                  "Delete * from sales as p where p.cost>10")
if(dbGetInfo(rs, what = "rowsAffected") > 250){
  warning("Rolling back transaction")
  dbRollback(con)
}else{
  dbCommit(con)
}
dbGetQuery(con, "select count(*) from sales")




require("RPostgreSQL")


# create a connection
drv <- dbDriver("PostgreSQL")
conn <- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")

# Insert DF
df <- data.frame(
  hmdb_id = c("m1"),
  names = c('{"rampage"}'),
  formula = c("C10H15N5O13P2S")
)

li <- list(
  hmdb_id = "m1",
  names = '{"rampage"}',
  formula = "C10H15N5O13P2S"
)

df <- data.frame(matrix(ncol = length(li), nrow = 0))
colnames(df) <- names(li)
df <- rbind(df, li)



dbBegin(conn)
dbWriteTable(conn, "hmdb_data", value = df, append = TRUE, row.names = FALSE)

dbCommit(conn)



dbDisconnect(conn)

