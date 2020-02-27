library(httr)

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
      SQL <- paste(c("SELECT
        kegg_id,hmdb_id,cas_id,chebi_id,lipidmaps_id,pubchem_id,
        names,formula,
        exact_mass,mol_weight,
        comments
        FROM chebi_data WHERE chebi_id = '", db_id ,"'"), collapse = "")
      df.kegg <- db.query(SQL)

      if(length(df.kegg) == 0) {
        .self$call_api(db_id)

        # todo: find in api
        return(NULL)
      }

      # convert to common interface:
      # convert pg array strings to R vectors:
      df.kegg$names <- list(pg_str2vector(df.kegg$names[[1]]))
      df.kegg$source <- c("kegg")
      df.kegg$metlin_id = c(NA)
      df.kegg$smiles = c(NA)
      df.kegg$inchi = c(NA)
      df.kegg$inchikey = c(NA)

      colnames(df.kegg)["exact_mass"] <- "monoisotopic_mass"
      colnames(df.kegg)["mol_weight"] <- "mass"

      return (df.kegg)
    }
  )
)
