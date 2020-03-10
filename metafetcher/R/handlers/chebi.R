source("R/db_ctx.R")
source("R/utils.R")


ChebiHandler <- setRefClass(Class = "ChebiHandler",
  fields = list(
    name = "character",
    sql_select = "character"
  ),
  methods = list(
    initialize=function(...) {
      callSuper(...)
        # Initialise fields here (place holder)...
        .self

      .self$sql_select = "pubchem_id, chebi_id, kegg_id, hmdb_id, lipidmaps_id,
        smiles, inchi, inchikey, formula, names,
        mass, monoisotopic_mass"
    },

    query_metabolite = function(db_id) {
      # Queries a ChEBI metabolite record and converts it to a common interface
      SQL <- "SELECT %s FROM chebi_data WHERE chebi_id = '%s'"
      df.chebi <- db.query(sprintf(SQL, .self$sql_select, db_id))

      if(length(df.chebi) == 0) {
        return(NULL)
      }

      # convert to common interface:
      df.chebi$names <- list(pg_str2vector(df.chebi$names[[1]]))
      df.chebi$source <- c("chebi")
      # df.chebi$metlin_id = c(NA)
      # df.chebi$cas_id = c(NA)

      return (df.chebi)
    },

    query_reverse = function(df.res) {
      return(NULL)
      # SQL <- "SELECT %s FROM chebi_data WHERE"
      #
      # hmdb_id <- df.res$hmdb_id[[1]]
      # pubchem_id <- df.res$pubchem_id[[1]]
      # kegg_id <- df.res$kegg_id[[1]]
      # lipidmaps_id <- df.res$lipidmaps_id[[1]]
      #
      # # construct complex reverse query
      # if (!is.na(hmdb_id))
      #   SQL <- paste(SQL, sprintf(" hmdb_id = '%s'", hmdb_id))
      # if (!is.na(pubchem_id))
      #   SQL <- paste(SQL, sprintf(" pubchem_id = '{}'", pubchem_id))
      # if (!is.na(kegg_id))
      #   SQL <- paste(SQL, sprintf(" kegg_id = '{}'", kegg_id))
      # if (!is.na(lipidmaps_id))
      #   SQL <- paste(SQL, sprintf(" lipidmaps_id = '{}'", lipidmaps_id))
      #
      # df.chebi <- db.query(sprintf(SQL, .self$sql_select))
      #
      # if(length(df.chebi) == 0) {
      #   return(NULL)
      # }
      #
      # df.chebi$names <- list(pg_str2vector(df.chebi$names[[1]]))
      # df.chebi$source <- c("chebi")
      #
      # return(df.chebi)
    }
  )
)
