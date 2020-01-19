require("RPostgreSQL")

# create a connection
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")


dbExistsTable(con, "metabolites")



# creates df, a data.frame with the necessary columns
data(mtcars)
df <- data.frame(carname = rownames(mtcars),
                 mtcars,
                 row.names = NULL)
df$carname <- as.character(df$carname)
rm(mtcars)

# writes df to the PostgreSQL database "postgres", table "cartable"
dbWriteTable(con, "cartable",
             value = df, append = TRUE, row.names = FALSE)

# query the data from postgreSQL
df_postgres <- dbGetQuery(con, "SELECT * from cartable")

# compares the two data.frames
identical(df, df_postgres)
# TRUE

# Basic Graph of the Data
require(ggplot2)
ggplot(df_postgres, aes(x = as.factor(cyl), y = mpg, fill = as.factor(cyl))) +
  geom_boxplot() + theme_bw()