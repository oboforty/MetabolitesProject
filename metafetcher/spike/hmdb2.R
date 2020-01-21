library(XML)
require("RPostgreSQL")

parse_func <- function (x) {

}


con <- file('snoop_dog.xml', "r")
xml <- paste(readLines(con))
x <- xmlToList(xmlParse(xml))


b <- serialize(x,NULL,ascii=F)
#meta <- parse_func(x)
length(b)
nchar(xml)


# Insert to DB
drv <- dbDriver("PostgreSQL")
conn <- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")


df <- data.frame(hmdb_id=c(x$accession), dxml=c(xml))
dbWriteTable(conn, "hmdb_data", value = df, append = TRUE, row.names = FALSE)
