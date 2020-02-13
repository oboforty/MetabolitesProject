library(XML)
source("R/db_ctx.R")
source("R/utils.R")
source("R/migrate.R")


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

parse_xml_iter <- function(filepath) {
  start_time <- Sys.time()

  # connect to DB
  db.connect()
  remigrate_hmdb(db_conn)
  db.transaction()

  i <- 0
  tag_state <- "none"
  tag_parent <- "none"
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
        # todo: pubchem doesn't work or is not present

        if (name == "metabolite") {
          # new metabolite XML
          hmdb_df <<- create_hmdb_record()
          tag_state <<- "none"
        } else if (name == "accession") {
          # resolve secondary / primary id (they have the same tag <accession>)
          if (tag_parent != "secondary_id")
            tag_state <<- "hmdb_id"
          else
            # todo: store secondary id somehow a budos kurva eletbe bazmeg
            tag_state <<- "none"
        } else if (name == "traditional_iupac")
          tag_state <<- "iupac_trad_name"
        else if (name == "chemical_formula")
          tag_state <<- "formula"
        else if (name == "drugbank_metabolite_id")
          # todo: remove? or what is this?
          tag_state <<- "drugbank_metabolite_id"
        else if (name == "average_molecular_weight")
          tag_state <<- "avg_mol_weight"
        else if (name == "monisotopic_molecular_weight")
          tag_state <<- "monoisotopic_mol_weight"
        else if (name == "secondary_accessions")
          tag_parent <<- "secondary_id"
        else if (name %in% hmdb_attribs) {
          tag_state <<- name
        } else {
          tag_state <<- "none"
        }
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

          db.write_df("hmdb_data", hmdb_df)

          if (mod(i, 500) == 0) {
            log <- paste(c("Inserting to DB...", i, round(as.numeric(Sys.time() - start_time),2), "seconds"), collapse=" ")
            print(log)

            # on buffer full commit & reset DB buffer
            db.commit()
            db.transaction()
          }
        } else if (name == "secondary_accessions") {
          # close parent
          tag_parent <<- "none"
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
  db.commit()
  db.disconnect()

  log <- paste(c("Done! Took", round(as.numeric(Sys.time() - start_time),2), "seconds"), collapse=" ")
  print(log)
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

    query_metabolite = function(db_id) {
      # Queries an HMDB metabolite record and converts it to a common interface
      SQL <- paste(c("SELECT hmdb_id, names,
            formula as formulas, smiles, inchi as inchis, inchikey as inchikeys,
            cas_id as cas_ids, kegg_id as kegg_ids, chebi_id as chebi_ids, pubchem_id as pubchem_ids
        FROM hmdb_data WHERE hmdb_id = '", db_id ,"'"), collapse = "")
      df.hmdb <- db.query(SQL)

      # convert pg array strings to R vectors:
      for (attr in c("names")) {
        v <- df.hmdb[[attr]][[1]]

        if (!is.empty(v)) {
          df.hmdb[[attr]] <- list(pg_str2vector(v))
        }
      }

      # convert to common interface:
      df.hmdb$source = c("hmdb")
      names(df.hmdb)[names(df.hmdb) == "hmdb_id"] <- "hmdb_ids"

      return (df.hmdb)
    }

  ))
}
