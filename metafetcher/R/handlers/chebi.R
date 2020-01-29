library(iterators)
require("RPostgreSQL")

# Commit buffer size
BDFL <- 5000

attribs <- c(
    "chebi_id",
    "smiles",
    "charge", "mass", "monoisotopic_mass"
)
attribs_vec <- c(
    "names", "iupac_names", "iupac_trad_names",
    "formulas", "inchis", "inchikeys",
    "description", "quality",
    "pubchem_ids", "kegg_ids", "hmdb_ids", "lipidmaps_ids", "cas_ids"
)

create_chebi_record <- function () {
  df <- data.frame(matrix(ncol = length(attribs)+length(attribs_vec), nrow = 1))
  colnames(df) <- c(attribs, attribs_vec)

  for (attri in attribs_vec) {
    df[[attri]] <- list(vector(length=0))
  }

  return(df)
}

is.empty <- function(v) {
  return(is.null(v) || is.na(v) || v == "" || v == "\n")
}

lstrip <- function(sr, sub) {
  return(substring(sr, nchar(sub)+1, nchar(sr)))
}

join <- function(v) {
  st <- paste(c('{"',paste(v, collapse = '","'),'"}'), collapse="")

  return(st)
}

remigrate <- function (conn) {
  # temporal: delete table
  if (dbExistsTable(conn, "chebi_data")) {
    dbRemoveTable(conn, "chebi_data")
  }

  # recreate table
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
}


parse_sdf_iter <- function(filepath) {
  start_time <- proc.time()

  # read file line by line
  f_con <- file(filepath, "r")
  it <- ireadLines(f_con)

  # empty error file
  er_con <- file('../tmp/errors/chebi_error_xml.txt', "w")
  close(er_con)

  # connect to DB
  drv <- dbDriver("PostgreSQL")
  db_conn <- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")

  remigrate(db_conn)
  dbBegin(db_conn)

  # data frame buffer for the DB
  j <- 1
  df_chebi <- create_chebi_record()
  state <- "something"

  repeat {
    line <- nextElem(it)

    if (startsWith(line, "$$$$")) {
      # metabolite parsing has ended, save to DB

      # transform vectors to postgres ARRAY input strings
      for (attr in attribs_vec) {
        v <- df_chebi[[attr]][[1]]

        if (length(v) > 0) {
          df_chebi[[attr]] <- c(join(v))
        } else {
          df_chebi[[attr]] <- c(NA)
        }
      }

      dbWriteTable(db_conn, "chebi_data", value = df_chebi, append = TRUE, row.names = FALSE)

      # iterate on parsed records counter
      j <- j + 1
      df_chebi <- create_chebi_record()

      if (j >= BDFL) {
        # commit every once in a while
        now <- proc.time()
        # round(now - start_time, 2)
        log <- paste(c("Inserting to DB...", j), collapse=" ")
        print(log)

        # on buffer full commit & reset DB buffer
        dbCommit(db_conn)
        dbBegin(db_conn)

        j <- 1
      }
    } else if (is.empty(line)) {
      next
    } else if (startsWith(line, ">")) {
      # new state
      state <- substr(line, 4, nchar(line)-1)
    } else {
      # todo: add names!
      if (state == 'ChEBI ID')
        df_chebi$chebi_id[[1]] <- lstrip(line, "CHEBI:")
      else if (state == 'IUPAC Names') {
        vec <- df_chebi$iupac_names[[1]]
        df_chebi$iupac_names[[1]] <- c(vec, line)

        # vec <- df_chebi$iupac_names[[1]]
        # df_chebi$iupac_names[[1]] <- c(vec, "line 2 man")
      }
      # else if (state == 'Formulae')
      #   df_chebi$formulas <- c(df_chebi$formulas, line)
      # else if (state == 'InChI')
      #   df_chebi$inchis <- c(df_chebi$inchis, lstrip(line, "InChI:"))
      # else if (state == 'InChIKey')
      #   df_chebi$inchikeys <- c(df_chebi$inchikeys, line)
      # else if (state == 'Definition')
      #   df_chebi$description <- c(df_chebi$description, line)
      # else if (state == 'Star')
      #   df_chebi$quality <- c(df_chebi$quality, line)
      # else if (state == 'PubChem Database Links' || state == 'Pubchem Database Links')
      #   df_chebi$pubchem_ids <- c(df_chebi$pubchem_ids, line)
      # else if (state == 'KEGG COMPOUND Database Links')
      #   df_chebi$kegg_ids <- c(df_chebi$kegg_ids, line)
      # else if (state == 'HMDB Database Links')
      #   df_chebi$hmdb_ids <- c(df_chebi$hmdb_ids, line)
      # else if (state == 'LIPID MAPS instance Database Links')
      #   df_chebi$lipidmaps_ids <- c(df_chebi$lipidmaps_ids, line)
      # else if (state == 'CAS Registry Numbers')
      #   df_chebi$cas_ids <- c(df_chebi$cas_ids, line)
      else if (state == 'SMILES')
        df_chebi$smiles <- line
      else if (state == 'Charge')
        df_chebi$charge <- line
      else if (state == 'Mass')
        df_chebi$mass <- line
      else if (state == 'Monoisotopic Mass')
        df_chebi$monoisotopic_mass <- line
    }
  }

  print("Closing DB & File")
  close(f_con)
  dbCommit(db_conn)
  dbDisconnect(db_conn)

  end_time <- Sys.time()
}

chebi <- function(fake = FALSE) {
  return(list(
    download_all = function() {
      filepath <- "../tmp/ChEBI_complete.sdf"

      if (!fake) {
        # todo: download that large xml
      }

      # parse file iteratively (line by line)
      parse_sdf_iter(filepath)
    },

    parse = function() {
      print("fake_metabolite chebi")
    },

    download = function() {
      print("download chebi")
    },

    fake = function() {
      print("fake chebi")
    },

    query = function() {
      print("query chebi")
    }
  ))
}
