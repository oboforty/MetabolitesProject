

#df.res <- read.csv("discovery.csv", stringsAsFactors=FALSE)


source('R/discover.R')
df.res <- resolve_single_id('hmdb_id', 'HMDB0035495')$df
