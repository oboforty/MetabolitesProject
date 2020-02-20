source("R/db_ctx.R")
source("R/utils.R")


HmdbHandler <- setRefClass(Class = "HmdbHandler",
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
      # Queries an HMDB metabolite record and converts it to a common interface
      SQL <- paste(c("SELECT
        pubchem_id, chebi_id, kegg_id, hmdb_id, metlin_id,
        smiles, inchi, inchikey, formula, names,
        avg_mol_weight as mass, monoisotopic_mol_weight as monoisotopic_mass
        FROM hmdb_data WHERE hmdb_id = '", db_id ,"'"), collapse = "")
      df.hmdb <- db.query(SQL)

      if(length(df.hmdb) == 0)
        return(NULL)

      # convert to common interface:
      # convert pg array strings to R vectors:
      df.hmdb$names <- list(pg_str2vector(df.hmdb$names[[1]]))
      df.hmdb$source <- c("hmdb")
      df.hmdb$lipidmaps_id <- c(NA)
      df.hmdb$cas_id = c(NA)

      return (df.hmdb)
    }
  )
)