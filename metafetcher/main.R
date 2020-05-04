
source('R/discover.R')



df.res <- read.csv("discovery2.csv", stringsAsFactors=FALSE)
resp <- resolve(df.res)

df.out <- resp$df




source('R/discover.R')
resp <- resolve_single_id('hmdb_id', 'HMDB0035495')
df.out <- resp$df

df.out <- revert_df(df.out)

