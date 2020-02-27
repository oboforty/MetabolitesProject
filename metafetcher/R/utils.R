library(stringr)

null2na <- function(v) {
  if (is.null(v))
    return(NA)
  else
    return(v)
}

is.empty <- function(v) {
  return(is.null(v) || is.na(v) || v == "" || v == "\n")
}

lstrip <- function(sr, sub) {
  return(substring(sr, nchar(sub)+1, nchar(sr)))
}

join <- function(v) {
  st <- paste(c('{"',paste(v, collapse = '","'),'"}'), collapse="")

  return(st)
}

pg_vector2str <- function (m) {
  # todo: later
}

pg_str2vector <- function (x) {
  # return found groups of "anystring"
  pattern <- "\"(.+?)\""
  m <- str_match_all(x, pattern)[[1]][,2]

  # if there was no match, then the x string itself is already a word
  if (length(m) == 0)
    return(substr(x, 2, nchar(x)-1))

  # find single words in the rest of the unmatched string
  pattern2 <- "[a-zA-Z0-9_-]+"
  m <- c(m, str_match_all(paste(str_split(x, pattern)[[1]], collapse=""), pattern2)[[1]])

  return(m)
}


mod<-function(x,m) {
  t1<-floor(x/m)
  return(x-t1*m)
}


attr.refs <- c(
    "chebi_id", "hmdb_id", "lipidmaps_id",
    "kegg_id", "metlin_id", "pubchem_id", "cas_id"
)

attr.meta <- c(
    "names", "mass", "monoisotopic_mass",
    "formula", "inchi", "inchikey", "smiles",

    attr.refs
)

create_empty_record <- function () {
  df <- data.frame(matrix(ncol = length(attr.meta), nrow = 1))
  colnames(df) <- attr.meta

  # for (attr in attr.meta) {
  #   df[[attr]] <- list(vector(length=0))
  # }

  return(df)
}
