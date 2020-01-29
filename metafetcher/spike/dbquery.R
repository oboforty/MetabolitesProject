require("RPostgreSQL")


# create a connection
drv <- dbDriver("PostgreSQL")
conn <- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")



dbGetQuery(conn, "CREATE TABLE chebi_data (
	names TEXT[],
	iupac_names TEXT[],
	iupac_trad_names TEXT[],
	formulas TEXT[],
	smiles TEXT,
	inchis TEXT[],
	inchikeys TEXT[],
	chebi_id VARCHAR(20) NOT NULL,
	description TEXT,
	quality INTEGER,
	comments TEXT,
	cas_ids VARCHAR[],
	kegg_ids VARCHAR[],
	hmdb_ids VARCHAR[],
	lipidmaps_ids VARCHAR[],
	pubchem_ids VARCHAR[],
	charge FLOAT,
	mass FLOAT,
	monoisotopic_mass FLOAT,
	list_of_pathways TEXT,
	kegg_details TEXT,

	PRIMARY KEY (chebi_id)
  )")




# Insert DF
df <- data.frame(
  iupac_names = NA,
  chebi_id = c('4122')
)

df$iupac_names <- list('{"NA","(2R,3R)-2-(3,4-dihydroxyphenyl)-3,4-dihydro-2H-chromene-3,5,7-triol", "a_budos_kurva_anyad_te_szerencsetlen"}')

#df[["iupac_names"]] <- unlist(df[["iupac_names"]], use.names=FALSE)
#df$iupac_names <- unlist(df$iupac_names, use.names=FALSE)

df$iupac_names <- c(df$iupac_names[[1]])

dbWriteTable(conn, "chebi_data", value = df, append = TRUE, row.names = FALSE)


# Query from table
df_resp <- dbGetQuery(conn, "SELECT * from metabolites")

identical(df, df_resp)

