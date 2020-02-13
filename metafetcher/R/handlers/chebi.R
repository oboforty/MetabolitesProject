library(iterators)
source("R/db_ctx.R")
source("R/utils.R")

chebi_attribs <- c(
    "chebi_id",
    "smiles",
    "charge", "mass", "monoisotopic_mass"
)
chebi_attribs_vec <- c(
    "names", "iupac_names", "iupac_trad_names",
    "formulas", "inchis", "inchikeys",
    "description", "quality",
    "pubchem_ids", "kegg_ids", "hmdb_ids", "lipidmaps_ids", "cas_ids"
)

chebi_mapping <- list(

)

create_chebi_record <- function () {
  df <- data.frame(matrix(ncol = length(chebi_attribs)+length(chebi_attribs_vec), nrow = 1))
  colnames(df) <- c(chebi_attribs, chebi_attribs_vec)

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
      # todo: add names!
      if (state == 'ChEBI ID')
        df.chebi$chebi_id[[1]] <- lstrip(line, "CHEBI:")
      else if (state == 'IUPAC Names') {
        #df.chebi$iupac_names[[1]] <- c(df.chebi$iupac_names[[1]], line)

        # vec <- df.chebi$iupac_names[[1]]
        # df.chebi$iupac_names[[1]] <- c(vec, "line 2 man")
      }
      else if (state == 'Formulae')
        df.chebi$formulas[[1]] <- c(df.chebi$formulas[[1]], line)
      else if (state == 'InChI')
        df.chebi$inchis[[1]] <- c(df.chebi$inchis[[1]], line)
      else if (state == 'InChIKey')
        df.chebi$inchikeys[[1]] <- c(df.chebi$inchikeys[[1]], line)
      else if (state == 'Definition')
        df.chebi$description[[1]] <- c(df.chebi$description[[1]], line)
      # todo: star doesn't work
      # else if (state == 'Star')
      #   df.chebi$quality[[1]] <- c(df.chebi$quality[[1]], strtoi(line))
      else if (state == 'PubChem Database Links' || state == 'Pubchem Database Links')
        df.chebi$pubchem_ids[[1]] <- c(df.chebi$pubchem_ids[[1]], line)
      else if (state == 'KEGG COMPOUND Database Links')
        df.chebi$kegg_ids[[1]] <- c(df.chebi$kegg_ids[[1]], line)
      else if (state == 'HMDB Database Links')
        df.chebi$hmdb_ids[[1]] <- c(df.chebi$hmdb_ids[[1]], line)
      else if (state == 'LIPID MAPS instance Database Links')
        df.chebi$lipidmaps_ids[[1]] <- c(df.chebi$lipidmaps_ids[[1]], line)
      else if (state == 'CAS Registry Numbers')
        df.chebi$cas_ids[[1]] <- c(df.chebi$cas_ids[[1]], line)
      else if (state == 'SMILES')
        df.chebi$smiles <- line
      else if (state == 'Charge')
        df.chebi$charge <- line
      else if (state == 'Mass')
        df.chebi$mass <- line
      else if (state == 'Monoisotopic Mass')
        df.chebi$monoisotopic_mass <- line
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
      # Queries a ChEBI metabolite record and converts it to a common interface
      SQL <- paste(c("SELECT chebi_id, names,
            formulas, smiles, inchis, inchikeys,
            cas_ids, kegg_ids, hmdb_ids, pubchem_ids, lipidmaps_ids
        FROM chebi_data WHERE chebi_id = '", db_id ,"'"), collapse = "")
      df.chebi <- db.query(SQL)

      # convert pg array strings to R vectors:
      for (attr in chebi_attribs_vec) {
        v <- df.chebi[[attr]][[1]]

        if (!is.empty(v)) {
          df.chebi[[attr]] <- list(pg_str2vector(v))
        }
      }

      # convert to common interface:
      df.chebi$source = c("chebi")

      names(df.chebi)[names(df.chebi) == "chebi_id"] <- "chebi_ids"

      return (df.chebi)
    }

  ))
}
