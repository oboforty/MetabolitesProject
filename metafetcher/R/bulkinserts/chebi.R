library(iterators)
source("R/db_ctx.R")
source("R/utils.R")
source("R/migrate.R")


bulk_insert_lipidmaps <- function(filepath) {
  mapping.chebi <- list(
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

  # data frame buffer for the DB
  attr.chebi <- unique(unlist(mapping.chebi))
  # todo: cardinality: chebi_id_alt, ??maybe formulas??,
  mcard.chebi <- c(
    "names",
    # "formulas", "inchis", "inchikeys", "smiles",
    #"pubchem_ids", "pubchem_ids", "kegg_ids", "hmdb_ids", "lipidmaps_ids", "cas_ids"
  )
  df.chebi <- create_empty_record(1, attr.chebi, mcard.chebi)


  # connect to DB
  db.connect()
  remigrate_chebi(db_conn)
  db.transaction()

  # read file line by line
  f_con <- file(filepath, "r")
  it <- ireadLines(f_con)

  j <- 1
  state <- "something"
  start_time <- Sys.time()
  print("Inserting ChEBI to DB...")

  repeat {
    line <- nextElem(it)

    if (startsWith(line, "$$$$")) {
      # metabolite parsing has ended, save to DB
      # transform vectors to postgres ARRAY input strings
      df.chebi <- convert_df_to_db_array(df.chebi, mcard.chebi)
      db.write_df("lipidmaps_data", df.chebi)

      # iterate on parsed records counter
      j <- j + 1
      df.chebi <- create_empty_record(1, attr.chebi, mcard.chebi)

      if (mod(j, 500) == 0) {
        # commit every once in a while
        print(sprintf("#%s (%s s)", j, Sys.time() - start_time))

        db.commit()
        db.transaction()
      }
    } else if (is.empty(line)) {
      next
    } else if (startsWith(line, ">")) {
      # new state
      state <- substr(line, 4, nchar(line)-1)
    } else {
      attr <- mapping.chebi[[state]]

      if (!is.null(attr)) {
        if (attr == 'names') {
          df.chebi[[1, attr]] <- c(df.chebi[[1, attr]], line)
          next
        }

        if (attr == 'inchi')
          line <- lstrip(line, "InChI=")

        df.chebi[[1, attr]] <- line
      }
    }
  }

  # finish up

  print("Closing DB & File")
  close(f_con)
  db.commit()
  db.disconnect()

  print(sprintf("Done! Took %d seconds", round(as.numeric(Sys.time() - start_time),2)))
}

bulk_insert_lipidmaps("../tmp/chebi.sdf")
