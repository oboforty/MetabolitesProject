source("R/db_ctx.R")
source("R/utils.R")


ChebiHandler <- setRefClass(Class = "ChebiHandler",
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
      # Queries a ChEBI metabolite record and converts it to a common interface
      SQL <- "SELECT
        pubchem_id, chebi_id, kegg_id, hmdb_id, lipidmaps_id,
        smiles, inchi, inchikey, formula, names,
        mass, monoisotopic_mass
        FROM chebi_data WHERE chebi_id = '%s'"
      df.chebi <- db.query(sprintf(SQL, db_id))

      if(length(df.chebi) == 0) {
        return(NULL)
      }

      # convert to common interface:
      # convert pg array strings to R vectors:
      df.chebi$names <- list(pg_str2vector(df.chebi$names[[1]]))
      df.chebi$source <- c("chebi")
      df.chebi$metlin_id = c(NA)
      df.chebi$cas_id = c(NA)

      return (df.chebi)
    }
  )
)
