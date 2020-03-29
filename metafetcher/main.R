
source('R/discover.R')



#df.res <- read.csv("discovery.csv", stringsAsFactors=FALSE)
#df.res <- resolve(df.res)$df

df.res <- resolve_single_id('hmdb_id', 'HMDB0035495')$df

#df.res2 <- revert_df(df.res)
