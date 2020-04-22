
source('R/discover.R')



df.res <- read.csv("discovery.csv", stringsAsFactors=FALSE)
resp <- resolve(df.res)

#df.res <- resolve_single_id('hmdb_id', 'HMDB0035495')
#df.res2 <- revert_df(df.res)



df.out <- resp$df

