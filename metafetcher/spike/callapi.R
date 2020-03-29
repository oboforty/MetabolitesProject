library(httr)
library(stringi)


db_id = '71362326'

url <- 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/%s/json'
r <- GET(sprintf(url,db_id), timeout(resolve.options$http_timeout))
if (r$status != 200)
  return (NULL)
v <- content(r)

props <- v$PC_Compounds[[1]]$props

create_pubchem_record <- function () {
  pubchem_attribs <- c(
    "smiles", "inchi", "inchikey", "formula", "names",
    "mass", "monoisotopic_mass", "logp",

    "pubchem_id", "chebi_id",  "hmdb_id", "kegg_id",
    "ref_etc"
  )

  df <- data.frame(matrix(ncol = length(pubchem_attribs), nrow = 1))
  colnames(df) <- pubchem_attribs

  df$names <- list(vector(length=0))

  return(df)
}
df.pubchem <- create_pubchem_record()

# 1. Parse properties
# todo: multiple cardinality?
for (prop in props) {
  label <- prop$urn$label
  val <- prop$value

  if (label == 'InChI')
      df.pubchem$inchi <- val$sval
  else if (label == 'InChIKey')
      df.pubchem$inchikeys <- val$sval
  else if (label == 'SMILES')
      df.pubchem$smiles <- val$sval
  else if (label == 'IUPAC Name')
      df.pubchem$names <- val$sval
  else if (label == 'Molecular Formula')
      df.pubchem$formula <- val$sval
  else if (label == 'Mass')
      df.pubchem$mass <- val$fval
  else if (label == 'Molecular Weight')
      df.pubchem$weight <- val$fval
  else if (label == 'Weight' && prop$urn$name == 'MonoIsotopic')
      df.pubchem$monoisotopic <- val$fval
  else if (label == 'Log P')
      df.pubchem$logp <- val$fval
}


# 2. parse external references
url <- 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/%s/xrefs/SourceName,RegistryID/JSON'
r <- GET(sprintf(url,db_id), timeout(resolve.options$http_timeout))
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


