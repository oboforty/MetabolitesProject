library(httr)
library(stringi)

source("R/db_ctx.R")
source("R/utils.R")


create_pubchem_record <- function () {
  pubchem_attribs <- c(
    "smiles", "inchi", "inchikey", "formula", "names",
    "mass", "monoisotopic_mass", "logp",

    "pubchem_id", "chebi_id",  "hmdb_id", "kegg_id",
    "ref_etc"
  )

  df <- data.frame(matrix(ncol = length(pubchem_attribs), nrow = 1))
  colnames(df) <- pubchem_attribs

  # vector fields: names, smiles
  df$names <- list(vector(length=0))
  df$smiles <- list(vector(length=0))

  return(df)
}


PubchemHandler <- setRefClass(Class = "PubchemHandler",
  fields = list(
    name = "character"
  ),
  methods = list(
    initialize=function(...) {
      callSuper(...)
        # Initialise fields here (place holder)...
        .self
    },

    query_metabolite = function(db_id) {
      # Queries a KEGG metabolite record and converts it to a common interface
      SQL <- "SELECT
        pubchem_id, chebi_id, kegg_id, hmdb_id,
        smiles, inchi, inchikey, formula, names,
        mass, monoisotopic_mass, logp
        FROM pubchem_data WHERE pubchem_id = '%s'"
      df.pubchem <- db.query(sprintf(SQL, db_id))

      if (length(df.pubchem) == 0) {
        df.pubchem <- .self$call_api(db_id)

        # if api response is still empty, then the record doesn't exist
        if (is.null(df.pubchem) || length(df.pubchem) == 0)
          return(NULL)

        # Save to db
        if (length(df.pubchem$names[[1]]) > 0)
          df.pubchem$names <- c(join(df.pubchem$names[[1]]))
        if (length(df.pubchem$smiles[[1]]) > 0)
          df.pubchem$smiles <- c(join(df.pubchem$smiles[[1]]))

        # cache pubchem record
        #saveRDS(df.pubchem, "pubchem_data.rds")
        db.write_df("pubchem_data", df.pubchem)
      }

      # convert to common interface:
      # convert pg array strings to R vectors:
      df.pubchem$names <- list(pg_str2vector(df.pubchem$names[[1]]))
      df.pubchem$smiles <- list(pg_str2vector(df.pubchem$smiles[[1]]))
      df.pubchem$source <- c("pubchem")
      # df.pubchem$metlin_id = c(NA)
      # df.pubchem$lipidmaps_id = c(NA)
      # df.pubchem$chemspider_id = c(NA)

      return (df.pubchem)
    },

    query_reverse = function(df.res) {
      # todo: itt

      return(NULL)
    },

    call_api = function(db_id) {
      'Calls PubChem api to retrieve record.'
      df.pubchem <- create_pubchem_record()

      # 1. Parse properties
      url <- 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/%s/json'
      r <- GET(sprintf(url,db_id))

      if (r$status != 200)
        return (NULL)
      v <- content(r)
      df.pubchem$pubchem_id <- v$PC_Compounds[[1]]$id$id$cid

      props <- v$PC_Compounds[[1]]$props

      # todo: multiple cardinality?
      for (prop in props) {
        label <- prop$urn$label
        val <- prop$value

        if (label == 'InChI')
            df.pubchem$inchi <- val$sval
        else if (label == 'InChIKey')
            df.pubchem$inchikey <- val$sval
        else if (label == 'SMILES')
            df.pubchem$smiles[[1]] <- c(df.pubchem$smiles[[1]], val$sval)
        else if (label == 'IUPAC Name')
            df.pubchem$names[[1]] <- c(df.pubchem$names[[1]], val$sval)
        else if (label == 'Molecular Formula')
            df.pubchem$formula <- val$sval
        else if (label == 'Mass')
            df.pubchem$mass <- val$fval
        else if (label == 'Molecular Weight')
            df.pubchem$weight <- val$fval
        else if (label == 'Weight' && prop$urn$name == 'MonoIsotopic')
            df.pubchem$monoisotopic_mass <- val$fval
        else if (label == 'Log P')
            df.pubchem$logp <- val$fval
      }

      # 2. parse external references
      url <- 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/%s/xrefs/SourceName,RegistryID/JSON'
      r <- GET(sprintf(url,db_id))
      if (r$status != 200)
        return (NULL)

      v <- content(r)

      ids <- v$InformationList$Information[[1]]$RegistryID

      for (xdb_id in ids) {
        # todo: rest, e.g. chemspider?

        if (startsWith(xdb_id, 'CHEBI:'))
          df.pubchem$chebi_id <- xdb_id
        else if (startsWith(xdb_id, 'HMDB'))
          df.pubchem$hmdb_id <- xdb_id
        else if (substr(xdb_id, 1, 1) == 'C' && str_detect(xdb_id, '^C\\d{4,9}$'))
          df.pubchem$kegg_id <- xdb_id
      }
      print(df.pubchem)
      return(df.pubchem)
    }

  )
)
