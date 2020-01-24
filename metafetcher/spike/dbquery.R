require("RPostgreSQL")


# create a connection
drv <- dbDriver("PostgreSQL")
conn <- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")


# Create PG table
if (!dbExistsTable(con, "metabolites")) {
  dbGetQuery(conn, "CREATE TABLE hmdb_data (
	names ARRAY,
	iupac_name TEXT,
	iupac_trad_name TEXT,
	formula TEXT,
	smiles TEXT,
	inchi TEXT,
	inchikey TEXT,
	hmdb_id VARCHAR(11) NOT NULL,
	description TEXT,
	cas_id VARCHAR(10),
	drugbank_id VARCHAR(32),
	drugbank_metabolite_id VARCHAR(32),
	chemspider_id VARCHAR(32),
	kegg_id VARCHAR(32),
	metlin_id VARCHAR(32),
	pubchem_id VARCHAR(32),
	chebi_id VARCHAR(32),
	avg_mol_weight FLOAT,
	monoisotopic_mol_weight FLOAT,
	state VARCHAR(32),
	biofluid_locations ARRAY,
	tissue_locations ARRAY,
	taxonomy TEXT,
	ontology TEXT,
	proteins TEXT,
	diseases TEXT,
	synthesis_reference TEXT,

	PRIMARY KEY (hmdb_id)
  )")
}


# Insert DF
df <- data.frame(
  mid = c(1,2,3),

  names = c(NA, NA, '{"3\'-Phospho-5\'-adenylyl sulfate", "3\'-phospho-5\'-adenylyl sulfate", "3\'-Phosphoadenosine 5\'-phosphosulfate", "3\'-phosphoadenosine 5\'-phosphosulfate", "3\'-Phosphoadenylyl sulfate", "3\'-O-phosphono-5\'-adenylyl sulfate"}'),
  source = c("hmdb", "hmdb", "chebi"),

  formulae = c(NA, NA, "C10H15N5O13P2S"),

  hmdb_id = c("HMDB0001134", "HMDB0013116", NA),
  kegg_id = c("C00053", NA, "C00053"),
  chemspider_id = c("9799", "158232", NA),
  pubchem_id = c("10214", "181919", NA),
  chebi_id = c("17980", NA, "17980"),
  metlin_id = c("6028", NA, NA)
)

dbWriteTable(conn, "metabolites", value = df, append = TRUE, row.names = FALSE)


# Query from table
df_resp <- dbGetQuery(conn, "SELECT * from metabolites")

identical(df, df_resp)

