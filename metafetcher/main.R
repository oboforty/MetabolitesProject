

#df.res <- read.csv("discovery.csv", stringsAsFactors=FALSE)


source('R/discover.R')

df.res <- resolve_single_id('chebi_id', '16336')

