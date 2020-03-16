
source('R/utils.R')

df.res <- read.csv("discovery.csv", stringsAsFactors=FALSE)

df.new <- transform_df(df.res)


df.new[[2, 'hmdb_id']] <- c(df.new[[2, 'hmdb_id']], "asd")
