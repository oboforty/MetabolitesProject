

source('R/discover.R')

#df.res <- read.csv("discovery.csv", stringsAsFactors=FALSE)

#df.res <- resolve(df.res)



df.res <- resolve_single_id('hmdb_id', 'HMDB0006112')
