source('R/discover.R')

#resp <- resolve_single_id('pubchem_id', '16683874')

#df.out <- resp$df




df.res <- read.csv("discovery.csv", stringsAsFactors=FALSE)
resp <- resolve_metabolites(df.res)

df.out <- resp$df
