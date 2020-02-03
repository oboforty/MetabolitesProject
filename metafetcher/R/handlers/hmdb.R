library(XML)
require("RPostgreSQL")
source("R/handlers/utils.R")

hmdb_attribs <- c(
    "hmdb_id",
    "names", "iupac_name", "iupac_trad_name",
    "smiles", "formula", "inchi", "inchikey",

    "cas_id", "drugbank_id", "drugbank_metabolite_id", "chemspider_id", "kegg_id", "metlin_id", "pubchem_id", "chebi_id",
    "avg_mol_weight", "monoisotopic_mol_weight",
    "state", "description",

    "biofluid_locations",  "tissue_locations",
    "taxonomy", "ontology", "proteins", "diseases",
    "synthesis_reference"
)

# hmdb_attribs_vec <- c(
# )

create_hmdb_record <- function () {
  df <- data.frame(matrix(ncol = length(hmdb_attribs), nrow = 1))
  #colnames(df) <- c(hmdb_attribs, hmdb_attribs_vec)
  colnames(df) <- hmdb_attribs

  # for (attri in hmdb_attribs_vec) {
  #   df[[attri]] <- list(vector(length=0))
  # }

  return(df)
}


remigrate_hmdb <- function (conn) {
  # temporal: delete table
  if (dbExistsTable(conn, "hmdb_data")) {
    dbRemoveTable(conn, "hmdb_data")
  }

  # recreate table
  dbGetQuery(conn, "CREATE TABLE hmdb_data (
	names TEXT[],
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
	biofluid_locations TEXT[],
	tissue_locations TEXT[],
	taxonomy TEXT,
	ontology TEXT,
	proteins TEXT,
	diseases TEXT,
	synthesis_reference TEXT,

	PRIMARY KEY (hmdb_id)
  )")
}


parse_xml_iter <- function(filepath) {
  start_time <- Sys.time()

  # connect to DB
  drv <- dbDriver("PostgreSQL")
  db_conn <- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")

  remigrate_hmdb(db_conn)
  dbBegin(db_conn)

  i <- 0
  tag_state <- "none"
  hmdb_df <- NA

  # Iterative XML parsing. this iterates on each xml tag individually
  # And we store the appropriate values to our dataframe.

  xmlEventParse(
    file = filepath,
    handlers = list(
      startDocument = function() {
        #cat("Starting document\n")
      },
      startElement = function(name,attr) {
        if (name == "metabolite") {
          # new metabolite XML
          hmdb_df <<- create_hmdb_record()
          tag_state <<- "none"
        } else if (name == "accession")
          tag_state <<- "hmdb_id"
        else if (name == "description")
          tag_state <<- "description"
        else if (name == "iupac_name")
          tag_state <<- "iupac_name"
        else if (name == "traditional_iupac")
          tag_state <<- "iupac_trad_name"
        else if (name == "chemical_formula")
          tag_state <<- "formula"
        else if (name == "smiles")
          tag_state <<- "smiles"
        else if (name == "inchi")
          tag_state <<- "inchi"
        else if (name == "inchikey")
          tag_state <<- "inchikey"
        else if (name == "cas_id")
          tag_state <<- "cas_id"
        else if (name == "drugbank_id")
          tag_state <<- "drugbank_id"
        else if (name == "drugbank_metabolite_id")
          tag_state <<- "drugbank_metabolite_id"
        else if (name == "chemspider_id")
          tag_state <<- "chemspider_id"
        else if (name == "kegg_id")
          tag_state <<- "kegg_id"
        else if (name == "metlin_id")
          tag_state <<- "metlin_id"
        else if (name == "pubchem_id")
          tag_state <<- "pubchem_id"
        else if (name == "chebi_id")
          tag_state <<- "chebi_id"
        else if (name == "average_molecular_weight")
          tag_state <<- "avg_mol_weight"
        else if (name == "monisotopic_molecular_weight")
          tag_state <<- "monoisotopic_mol_weight"
        else if (name == "state")
          tag_state <<- "state"
        else if (name == "synthesis_reference")
          tag_state <<- "synthesis_reference"
        else
          tag_state <<- "none"
      },
      text = function(text) {
        # todo: @later: check data cardinality
        if (tag_state != "none")
          hmdb_df[[tag_state]][[1]] <<- text

        # hmdb_df[[tag_state]] <<- c(hmdb_df[[tag_state]], text)
        #if (is.na(hmdb_df[[tag_state]])) {
        #  hmdb_df[[tag_state]] <<- c(text)
        #}
      },
      endElement = function (name) {
        if (name == "metabolite") {
          i <<- i + 1

          dbWriteTable(db_conn, "hmdb_data", value = hmdb_df, append = TRUE, row.names = FALSE)

          if (mod(i, 5000) == 0) {
            log <- paste(c("Inserting to DB...", i, (round(Sys.time() - start_time,2)), "seconds"), collapse=" ")
            print(log)

            # on buffer full commit & reset DB buffer
            dbCommit(db_conn)
            dbBegin(db_conn)
          }
        }
      },
      endDocument = function() {
        print("ending document")
      }
    ),
    addContext = FALSE,
    useTagName = FALSE,
    ignoreBlanks = TRUE,
    trim = TRUE
  )

  # disconnect from DB
  print("Closing DB")
  dbCommit(db_conn)
  dbDisconnect(db_conn)

  end_time <- Sys.time()
  print(round(end_time - start_time,2))
}



hmdb <- function(fake = FALSE) {
  return(list(
    download_all = function() {
      filepath <- "../tmp/hmdb_metabolites.xml"

      if (!fake) {
        # todo: download that large xml
      }

      # parse file iteratively (line by line)
      parse_xml_iter(filepath)
    },

    parse = function() {
      print("fake_metabolite hmdb")
    },

    download = function() {
      print("download hmdb")
    },

    fake = function() {
      print("fake hmdb")
    },

    query = function() {
      print("query hmdb")
    }
  ))
}
