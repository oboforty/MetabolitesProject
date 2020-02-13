library(sets)
source("R/queue.R")

source("R/handlers/hmdb.R")
source("R/handlers/chebi.R")
# source("R/handlers/kegg.R")
# source("R/handlers/chemspider.R")
# source("R/handlers/pubchem.R")
# source("R/handlers/lipidmaps.R")
# source("R/handlers/metlin.R")


get_db <- function (db_tag) {
  if (db_tag == "chebi") {
    return(chebi())
  } else if (db_tag == "hmdb") {
    return(hmdb())
  } else if (db_tag == "kegg") {
    return(NULL)
    # return(kegg())
  } else if (db_tag == "chemspider") {
    return(NULL)
    # return(chemspider())
  } else if (db_tag == "pubchem") {
    return(NULL)
    # return(pubchem())
  } else if (db_tag == "lipidmaps") {
    return(NULL)
    # return(lipidmaps())
  } else if (db_tag == "metlin") {
    return(NULL)
    # return(metlin())
  }

  # database is not supported by this package:
  return(NULL)
}

attr.refs <- c(
    "chebi_ids", "kegg_ids", "hmdb_ids",
    "pubchem_ids", "lipidmaps_ids", "cas_ids"
)

attr.meta <- c(
    "names",
    "formulas", "inchis", "inchikeys", "smiles",

    attr.refs
)

create_empty_record <- function () {
  df <- data.frame(matrix(ncol = length(attr.meta), nrow = 1))
  colnames(df) <- attr.meta

  for (attr in attr.meta) {
    df[[attr]] <- list(vector(length=0))
  }

  return(df)
}


download <- function(db_tag) {
  # downloads whole database

  db <- get_db(db_tag)

  db$download_all()
}


discover <- function(start_db_tag, start_db_id) {
  # downloads whole database
  discovered <- set()
  undiscovered <- set()

  df.discovered <- create_empty_record()

  # queue for the discover algorithm
  Q <- Queue()
  Q$push(tuple(start_db_tag, start_db_id, "root"))

  while (Q$size() > 0) {
    tpl <- Q$pop()
    db_tag <- tpl[[1]]
    db_id <- tpl[[2]]
    # db_ref_origin <- tpl[[3]]

    db <- get_db(db_tag)

    if (is.null(db)) {
      df.result <- NULL
    } else {
      print(paste(c("Fetching:", db_tag, db_id), collapse=" "))
      df.result <- db$query_metabolite(db_id)
    }

    if (is.null(df.result)) {
      # add to undiscovered set
      undiscovered <- c(undiscovered, tpl)
      next
    }

    discovered <- c(discovered, tuple(db_tag, db_id))

    # merge result with previously discovered data
    for (attr in attr.meta) {
      new.val <- df.result[[attr]][[1]]
      old.val <- df.discovered[[attr]][[1]]

      if (length(new.val) > 0 && !is.na(new.val)) {
         df.discovered[[attr]][[1]] <- c(old.val, new.val)
      }
    }

    # parse reference IDs and add them to queue
    for (attr in attr.refs) {
      new_db_id <- df.result[[attr]][[1]]

      # check if such refId is present in the record
      if (!is.empty(new_db_id)) {
        # 'hmdb_ids' ==> 'hmdb'
        new_db_tag <- substr(attr, 1, nchar(attr)-4)

        if (!set_contains_element(discovered, tuple(new_db_tag, new_db_id))) {
          # enqueue for exploration, but only if it hasn't occured before
          # Format: (db_tag, db_id, db_tag that referenced this id)
          Q$push(tuple(new_db_tag, new_db_id, db_tag))
        }
      }
    }
  }

  # release DB connection
  db.disconnect()

  return(df.discovered)
}

