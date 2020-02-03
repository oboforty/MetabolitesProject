attribs <- c(
  "chebi_id",
  "smiles",
  "charge", "mass", "monoisotopic_mass"
)
attribs_vec <- c(
  "names", "iupac_names", "iupac_trad_names",
  "formulas", "inchis", "inchikeys",
  "description", "quality",
  "pubchem_ids", "kegg_ids", "hmdb_ids", "lipidmaps_ids", "cas_ids"
)

create_chebi_record <- function () {
  df <- data.frame(matrix(ncol = length(attribs)+length(attribs_vec), nrow = 1))
  colnames(df) <- c(attribs, attribs_vec)

  for (attri in attribs_vec) {
    df[[attri]] <- list(vector(length=0))
  }

  return(df)
}

df_chebi = create_chebi_record()


df_chebi[[attr]][[1]] <- c(df_chebi[[attr]][[1]], "242")
df_chebi[[attr]][[1]] <- c(df_chebi[[attr]][[1]], "512")



attr = "iupac_names"


join <- function(v) {
  st <- paste(c('{"',paste(v, collapse = '","'),'"}'), collapse="")

  return(st)
}


# ---------------------------------
vec <- df_chebi$iupac_names[[1]]

df_chebi$iupac_names[[1]] <- c(vec, "1111")



# ---------------------------------


v <- df_chebi[[attr]][[1]]


join(v)

df_chebi[[attr]] <- c(join(v))








rr <- function () {
  a <- a + 1

  print(a)
}
a <- 1
rr()




















# todo itt

st <- join(df$chebi_id[[1]])



var = "chebi_id"

df[[var]][[1]] <- st

df$chebi_id[[1]] <- st


# -------------------------------------------------------------
# -------------------------------------------------------------



v <- vector(length=0)

if (length(v) == 0) {
  print(111)
}







# -------------------------------------------------------------
# -------------------------------------------------------------

attribs <- c(
  "chebi_id",
  "charge", "mass", "monoisotopic_mass"
)
attribs_vec <- c(
  "names", "iupac_names", "iupac_trad_names",
  "formulas", "smiles", "inchis", "inchikeys",
  "description", "quality",
  "pubchem_ids", "kegg_ids", "hmdb_ids", "lipidmaps_ids", "cas_ids"
)


create_chebi_record <- function () {
  df <- data.frame(matrix(ncol = length(attribs)+length(attribs_vec), nrow = 1))
  colnames(df) <- c(attribs, attribs_vec)

  for (attri in attribs_vec) {
    df[[attri]] <- list(vector(length=0))
  }

  return(df)
}

df <- create_chebi_record()

if (length(df$names[[1]]) ==0) {
  print(1)
}
