library(XML)


filepath <- "../tmp/hmdb_metabolites.xml"

mod<-function(x,m) {
  t1<-floor(x/m)
  return(x-t1*m)
}

hmdb_df <- NA

create_df <- function() {

  df <- list(
    hmdb_id = NA,
    description = NA,
    names = NA,
    iupac_name = NA,
    iupac_trad_name = NA,
    formula = NA,
    smiles = NA,
    inchi = NA,
    inchikey = NA,
    cas_id = NA,
    drugbank_id = NA,
    drugbank_metabolite_id = NA,
    chemspider_id = NA,
    kegg_id = NA,
    metlin_id = NA,
    pubchem_id = NA,
    chebi_id = NA,
    avg_mol_weight = NA,
    monoisotopic_mol_weight = NA,
    state = NA,
    biofluid_locations = NA,
    tissue_locations = NA,
    taxonomy = NA,
    ontology = NA,
    proteins = NA,
    diseases = NA,
    synthesis_reference = NA
  )

  return(df)
}


doit <- function() {
  i <- 0
  tag_state <- "none"

  qqpp <- 123

  xmlEventParse(
    file = filepath,
    handlers = list(
      startDocument = function() {
        #cat("Starting document\n")
      },
      startElement = function(name,attr) {
        print(qqpp)


        if (name == "metabolite") {
          # new metabolite XML

          hmdb_df <<- create_df()
          tag_state <<- "none"

        } else if (name == "accession")
          tag_state <<- "hmdb_id"
        else if (name == "description")
          tag_state <<- "description"
        else if (name == "iupac_name")
          tag_state <<- "iupac_name"
        else if (name == "traditional_iupac")
          tag_state <<- "iupac_trad_name"
        else if (name == "chemical_formula")
          tag_state <<- "formula"
        else if (name == "smiles")
          tag_state <<- "smiles"
        else if (name == "inchi")
          tag_state <<- "inchi"
        else if (name == "inchikey")
          tag_state <<- "inchikey"
        else if (name == "cas_id")
          tag_state <<- "cas_id"
        else if (name == "drugbank_id")
          tag_state <<- "drugbank_id"
        else if (name == "drugbank_metabolite_id")
          tag_state <<- "drugbank_metabolite_id"
        else if (name == "chemspider_id")
          tag_state <<- "chemspider_id"
        else if (name == "kegg_id")
          tag_state <<- "kegg_id"
        else if (name == "metlin_id")
          tag_state <<- "metlin_id"
        else if (name == "pubchem_id")
          tag_state <<- "pubchem_id"
        else if (name == "chebi_id")
          tag_state <<- "chebi_id"
        else if (name == "average_molecular_weight")
          tag_state <<- "avg_mol_weight"
        else if (name == "monisotopic_molecular_weight")
          tag_state <<- "monoisotopic_mol_weight"
        else if (name == "state")
          tag_state <<- "state"
        else if (name == "synthesis_reference")
          tag_state <<- "synthesis_reference"
        else
          tag_state <<- "none"
      },
      text = function(text) {
        if (tag_state != "none")
          hmdb_df[[tag_state]] <<- c(hmdb_df[[tag_state]], text)

        #if (is.na(hmdb_df[[tag_state]])) {
        #  hmdb_df[[tag_state]] <<- c(text)
        #}
      },
      endElement = function (name) {
        if (name == "metabolite") {
          i <<- i + 1

          if (mod(i, 1000) == 0)
            print(i)
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
}


print("STARTED")
start_time <- Sys.time()

doit()

print("FINISHED")
end_time <- Sys.time()
print(round(end_time - start_time,2))



hmdb_df$state
