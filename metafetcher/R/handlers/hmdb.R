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
      # treat obvious cases of secondary HMDB id:
      if (nchar(db_id) == 9) {
        db_id <- sprintf('HMDB00%s',substr(db_id, 5, nchar(db_id)))
      }

      # Queries an HMDB metabolite record and converts it to a common interface
      SQL <- "SELECT
        pubchem_id, chebi_id, kegg_id, hmdb_id, metlin_id,
        smiles, inchi, inchikey, formula, names,
        avg_mol_weight as mass, monoisotopic_mol_weight as monoisotopic_mass
        FROM hmdb_data WHERE hmdb_id = '%s'"
      df.hmdb <- db.query(sprintf(SQL, db_id))

      if(length(df.hmdb) == 0) {
        return(NULL)
      }

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