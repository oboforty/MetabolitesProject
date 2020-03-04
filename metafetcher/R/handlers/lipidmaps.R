source("R/db_ctx.R")
source("R/utils.R")


LipidmapsHandler <- setRefClass(Class = "LipidmapsHandler",
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
        mass
        FROM lipidmaps_data WHERE lipidmaps_id = '%s'"
      df.lipidmaps <- db.query(sprintf(SQL, db_id))

      if(length(df.lipidmaps) == 0)
        return(NULL)

      # convert to common interface:
      df.lipidmaps$names <- list(pg_str2vector(df.hmdb$names[[1]]))
      df.lipidmaps$source = c("lipidmaps")
      df.lipidmaps$metlin_id = c(NA)
      df.lipidmaps$cas_id = c(NA)
      df.lipidmaps$monoisotopic_mass = c(NA)

      return (df.lipidmaps)
    }
  )
)