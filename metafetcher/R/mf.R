source("R/handlers/hmdb.R")
source("R/handlers/chebi.R")
source("R/handlers/kegg.R")
source("R/handlers/chemspider.R")
source("R/handlers/pubchem.R")
source("R/handlers/lipidmaps.R")
source("R/handlers/metlin.R")


get_db <- function (db_tag) {
  if (db_tag == "hmdb") {
    return(hmdb())
  } else if (db_tag == "chebi") {
    return(chebi())
  } else if (db_tag == "kegg") {
    return(kegg())
  } else if (db_tag == "chemspider") {
    return(chemspider())
  } else if (db_tag == "pubchem") {
    return(pubchem())
  } else if (db_tag == "lipidmaps") {
    return(lipidmaps())
  } else if (db_tag == "metlin") {
    return(metlin())
  } else {
    stop(paste("Unknown database ", db_tag))
  }
}



download <- function(db_tag) {
  # downloads whole database

  db <- get_db(db_tag)

  db$download_all()
}


get_metabolite <- function(db_tag, db_id) {
  # fetches from api

  # todo: try to query from INTERNAL DB

  # todo: only THEN call the external db implementation!

  # todo: if found, THEN call specific data or IDK

  db <- get_db(db_tag)
}
