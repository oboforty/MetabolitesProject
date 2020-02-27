library(httr)
library(stringi)

kegg_attribs_vec <- c(
  "names"
)
kegg_attribs <- c(
  "exact_mass", "mol_weight",
  "comments", "formula",

  "kegg_id", "cas_id", "chebi_id",  "lipidmaps_id", "pubchem_id",

  "ref_etc",
  kegg_attribs_vec
)

create_kegg_record <- function () {
  df <- data.frame(matrix(ncol = length(kegg_attribs), nrow = 1))
  colnames(df) <- kegg_attribs

  for (attri in kegg_attribs_vec) {
    df[[attri]] <- list(vector(length=0))
  }

  return(df)
}

df.kegg <- create_kegg_record()





url <- 'http://rest.kegg.jp/get/cpd:'
db_id <- 'C21604'

r <- GET(paste(c(url,db_id), collapse=""))
lines <- strsplit(content(r), "\n", fixed = TRUE, useBytes=TRUE)

state <- NA

for (line in lines[[1]]) {
  if (line == "///" || line == "") {
    next
  }

  parts <- strsplit(line, "\\s+")[[1]]

  if (parts[[1]] == "") {
    # remove first empty part in line:
    parts <- parts[-1]
  }

  if (!startsWith(line, "   ")) {
    # new label starts in line:
    state <- parts[[1]]
    parts <- parts[-1]
  }

  if ("ENTRY" == state)
    df.kegg$kegg_id <- parts[[1]]
  else if ("NAME" == state) {
    df.kegg$names[[1]] <- c(df.kegg$names[[1]], parts)
  }
  else if ("FORMULA" == state)
    df.kegg$formula[[1]] <- parts[[1]]
  else if ("EXACT_MASS" == state)
    df.kegg$exact_mass[[1]] <- parts[[1]]
  else if ("MOL_WEIGHT" == state)
    df.kegg$mol_weight[[1]] <- parts[[1]]
  else if ("DBLINKS" == state) {
    db_tag <- tolower(parts[[1]])
    db_tag <- substr(db_tag, 1, nchar(db_tag)-1)
    if (!endsWith(db_tag, "_id"))
      db_tag <- paste(c(db_tag, "_id"), collapse = "")

    # remove db_tag and parse the rest of line as db_id
    parts <- parts[-1]

    if (length(parts) == 1) {
      # simply store
      df.kegg[[db_tag]][[1]] <- parts[[1]]
    } else {
      # todo: store in json string for refs
      # for (db_id in parts) {
      #   df.kegg[[db_tag]][[1]] <- c(df.kegg[[db_tag]][[1]], db_id)
      # }
    }
  }
}

print(1)





#
# class(content(r)partition("\n"))
#
# lines <-
#
# kegg_content <- str(content(r))
# lines <- stri_split_lines(kegg_content)
#
# for (line in lines) {
#   print(line)
# }
