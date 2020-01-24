library(XML)
library(iterators)
library(jsonlite)
require("RPostgreSQL")

# String buffer size
BL <- 1000

# Commit buffer size
BDFL <- 100

# the script commits to database after reaching this many bytes in the buffer
#COMMIT_SIZE <- 200*1024*1024


create_empty_dfvec <- function (N) {
  df_vect <- list(
    hmdb_id = character(N),
    description = character(N),
    names = character(N),
    iupac_name = character(N),
    iupac_trad_name = character(N),
    formula = character(N),
    smiles = character(N),
    inchi = character(N),
    inchikey = character(N),
    cas_id = character(N),
    drugbank_id = character(N),
    drugbank_metabolite_id = character(N),
    chemspider_id = character(N),
    kegg_id = character(N),
    metlin_id = character(N),
    pubchem_idd = character(N),
    chebi_id = character(N),
    avg_mol_weight = numeric(N),
    monoisotopic_mol_weight = numeric(N),
    state = character(N),
    biofluid_locations = character(N),
    tissue_locations = character(N),
    taxonomy = character(N),
    ontology = character(N),
    proteins = character(N),
    diseases = character(N),
    synthesis_reference = character(N)
  )

  return(df_vect)
}

nna <- function(v) {
  if (is.null(v))
    return(NA)
  else
    return(v)
}

parse_xml_iter <- function(filepath) {
  start_time <- proc.time()

  n_parsed <- 0

  # read file line by line
  con <- file(filepath, "r")
  it <- ireadLines(con)

  # ignore first two lines
  nextElem(it)
  nextElem(it)

  # buffer for the XML parsing
  i <- 1
  buffer <- character(BL)
  xml <- ""

  # data frame buffer for the DB
  j <- 1
  vec_df <- create_empty_dfvec(BDFL)

  buffer_size <- 0

  # empty error file
  er_con <- file('../tmp/errors/hmdb_error_xml.txt', "w")
  close(er_con)

  # connect to DB
  drv <- dbDriver("PostgreSQL")
  db_conn <- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")

  repeat {
    line <- nextElem(it)
    buffer[i] <- line
    i <- i + 1

    if (i >= BL) {
      # empty buffer
      xml <- paste(xml, paste(buffer, collapse=''))
      i <- 1
    }
    else if (line == "</metabolite>") {
      xmlend <- paste(buffer[1:i-1], collapse='')
      xml <- paste(xml, xmlend, collapse='')

      i <- 1

      # parse xml
      tryCatch({
        x <- xmlToList(xmlParse(xml))
      }, error = function(e) {
        print(paste("Error in XML. ", i))

        er_con <- file('../tmp/errors/hmdb_error_xml.txt', "a")
        write(xml, er_con)
        close(er_con)


        # todo: itt: dump file
      })

      # add entry to DF:
      vec_df$hmdb_id[j] <- nna(x$accession)
      vec_df$description[j] <- nna(x$description)

      vec_df$names[j] <- NA
      vec_df$iupac_name[j] <- nna(x$iupac_name)
      vec_df$iupac_trad_name[j] <- nna(x$traditional_iupac)
      vec_df$formula[j] <- nna(x$chemical_formula)
      vec_df$smiles[j] <- nna(x$smiles)
      vec_df$inchi[j] <- nna(x$inchi)
      vec_df$inchikey[j] <- nna(x$inchikey)

      vec_df$cas_id[j] <- nna(x$cas_id)
      vec_df$drugbank_id[j] <- nna(x$drugbank_id)
      vec_df$drugbank_metabolite_id[j] <- nna(x$drugbank_metabolite_id)
      vec_df$chemspider_id[j] <- nna(x$chemspider_id)
      vec_df$kegg_id[j] <- nna(x$kegg_id)
      vec_df$metlin_id[j] <- nna(x$metlin_id)
      vec_df$pubchem_id[j] <- nna(x$pubchem_id)
      vec_df$chebi_id[j] <- nna(x$chebi_id)
      vec_df$avg_mol_weight[j] <- nna(x$average_molecular_weight)
      vec_df$monoisotopic_mol_weight[j] <- nna(x$monisotopic_molecular_weight)
      vec_df$state[j] <- nna(x$state)
      # [f['biofluid'] for f in x$biofluid_locations [])]
      vec_df$biofluid_locations[j] <- NA
      # [f['tissue'] for f in x$tissue_locations [])]
      vec_df$tissue_locations[j] <- NA

      vec_df$taxonomy[j] <- toJSON(x$taxonomy)
      vec_df$ontology[j] <- toJSON(x$ontology)
      vec_df$proteins[j] <- toJSON(x$protein_associations)
      vec_df$diseases[j] <- toJSON(x$diseases)


      vec_df$synthesis_reference[j] <- nna(x$synthesis_reference)


      # keep DF buffer
      j <- j + 1
      buffer_size <- buffer_size + nchar(xml)

      #if (j >= BDFL || buffer_size >= COMMIT_SIZE) {
      if (j >= BDFL) {
        # save DB buffer as dataframe
        df <- data.frame(
          hmdb_id=vec_df$hmdb_id,description=vec_df$description,names=vec_df$names,iupac_name=vec_df$iupac_name,iupac_trad_name=vec_df$iupac_trad_name,formula=vec_df$formula,smiles=vec_df$smiles,inchi=vec_df$inchi,inchikey=vec_df$inchikey,cas_id=vec_df$cas_id,drugbank_id=vec_df$drugbank_id,drugbank_metabolite_id=vec_df$drugbank_metabolite_id,chemspider_id=vec_df$chemspider_id,kegg_id=vec_df$kegg_id,metlin_id=vec_df$metlin_id,pubchem_id=vec_df$pubchem_id,chebi_id=vec_df$chebi_id,avg_mol_weight=vec_df$avg_mol_weight,monoisotopic_mol_weight=vec_df$monoisotopic_mol_weight,state=vec_df$state,biofluid_locations=vec_df$biofluid_locations,tissue_locations=vec_df$tissue_locations,taxonomy=vec_df$taxonomy,ontology=vec_df$ontology,proteins=vec_df$proteins,diseases=vec_df$diseases,synthesis_reference=vec_df$synthesis_reference
        )
        #dbWriteTable(db_conn, "hmdb_data", value = head(df, j), append = TRUE, row.names = FALSE)
        dbWriteTable(db_conn, "hmdb_data", value = df, append = TRUE, row.names = FALSE)

        now <- proc.time()
        log <- paste("Inserting to DB... ", j, " ", round(now - start_time, 2), " seconds")
        print(log)

        # reset db buffers
        df_vect <- create_empty_dfvec(BDFL)
        j <- 1
        buffer_size <- 0

        # try to fight memory issues
        gc()
      }

      # clear buffer
      n_parsed <- n_parsed + 1
      xml <- ""
    }
  }

  print("Closing DB & File")
  close(con)
  close(db_conn)


  end_time <- Sys.time()
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
