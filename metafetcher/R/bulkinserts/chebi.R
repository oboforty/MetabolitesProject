library(iterators)
source("R/db_ctx.R")
source("R/utils.R")

chebi_attribs_vec <- c(
    "names", "iupac_names", "iupac_trad_names",
    "formulas", "inchis", "inchikeys",
    "description", "quality",
    "pubchem_ids", "kegg_ids", "hmdb_ids", "lipidmaps_ids", "cas_ids"
)

chebi_attribs <- c(
    "chebi_id",
    "smiles",
    "charge", "mass", "monoisotopic_mass",
    chebi_attribs_vec
)

chebi_mapping <- list(
  'ChEBI ID' = 'chebi_id',

  'ChEBI Name' = 'names',
  'IUPAC Name' = 'names',

  'Formulae' = 'formulas',
  'InChI' = 'inchis',
  'InChIKey' = 'inchikeys',
  'SMILES' = 'smiles',

  'Definition' = 'description',
  'PubChem Database Links' = 'pubchem_ids',
  'Pubchem Database Links' = 'pubchem_ids',
  'KEGG COMPOUND Database Links' = 'kegg_ids',
  'HMDB Database Links' = 'hmdb_ids',
  'LIPID MAPS instance Database Links' = 'lipidmaps_ids',
  'CAS Registry Numbers' = 'cas_ids',

  #'Star' = 'quality',
  'Charge' = 'charge',
  'Mass' = 'mass',
  'Monoisotopic Mass' = 'monoisotopic_mass'
)

create_chebi_record <- function () {
  df <- data.frame(matrix(ncol = length(chebi_attribs), nrow = 1))
  colnames(df) <- chebi_attribs

  for (attri in chebi_attribs_vec) {
    df[[attri]] <- list(vector(length=0))
  }

  return(df)
}

parse_sdf_iter <- function(filepath) {
  start_time <- Sys.time()

  # read file line by line
  f_con <- file(filepath, "r")
  it <- ireadLines(f_con)

  # empty error file
  er_con <- file('../tmp/errors/chebi_error_xml.txt', "w")
  close(er_con)

  # connect to DB
  db.connect()
  remigrate_chebi(db_conn)
  db.transaction()

  # data frame buffer for the DB
  j <- 1
  df.chebi <- create_chebi_record()
  state <- "something"

  repeat {
    line <- nextElem(it)

    if (startsWith(line, "$$$$")) {
      # metabolite parsing has ended, save to DB

      # transform vectors to postgres ARRAY input strings
      for (attr in chebi_attribs_vec) {
        v <- df.chebi[[attr]][[1]]

        if (length(v) > 0) {
          df.chebi[[attr]] <- c(join(v))
        } else {
          df.chebi[[attr]] <- c(NA)
        }
      }

      db.write_df("chebi_data", df.chebi)

      # iterate on parsed records counter
      j <- j + 1
      df.chebi <- create_chebi_record()

      if (mod(j, 500) == 0) {
        # commit every once in a while
        log <- paste(c("Inserting to DB...", j, round(as.numeric(Sys.time() - start_time),2), "seconds"), collapse=" ")
        print(log)

        # on buffer full commit & reset DB buffer
        db.commit()
        db.transaction()
      }
    } else if (is.empty(line)) {
      next
    } else if (startsWith(line, ">")) {
      # new state
      state <- substr(line, 4, nchar(line)-1)
    } else {
      attr <- chebi_mapping[[state]]

      if (state == 'ChEBI ID')
        df.chebi$chebi_id[[1]] <- lstrip(line, "CHEBI:")

      else if (!is.null(attr)) {
        if (attr %in% chebi_attribs_vec) {
          # cardinality > 1
          df.chebi[[attr]][[1]] <- c(df.chebi[[attr]][[1]], line)
        } else {
          df.chebi[[attr]] <- line
        }
      }
    }
  }

  print("Closing DB & File")
  close(f_con)
  db.commit()
  db.disconnect()

  log <- paste(c("Done! Took", round(as.numeric(Sys.time() - start_time),2), "seconds"), collapse=" ")
  print(log)
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

    query_metabolite = function(db_id) {
    }

  ))
}
