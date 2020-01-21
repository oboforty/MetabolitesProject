require("RPostgreSQL")


# create a connection
drv <- dbDriver("PostgreSQL")
conn <- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")


# Create PG table
if (!dbExistsTable(con, "metabolites")) {
  dbGetQuery(conn, "CREATE TABLE metabolites (
  	mid INTEGER NOT NULL,
  	downloaded_at TIMESTAMP DEFAULT now(),
  	names VARCHAR[40][],
  	source VARCHAR(20),

  	hmdb_id VARCHAR(128),
  	chebi_id VARCHAR(128),
  	kegg_id VARCHAR(128),
  	pubchem_id VARCHAR(128),
  	chemspider_id VARCHAR(128),
  	lipidmaps_id VARCHAR(128),
  	metlin_id VARCHAR(128),

  	formulae TEXT,
  	SMILES TEXT,
  	INCHI TEXT,

  	refs_etc json,
  	data json,

  	PRIMARY KEY (mid)
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

