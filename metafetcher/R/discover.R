library(sets)
source("R/queue.R")
source("R/utils.R")

source("R/handlers/hmdb.R")
source("R/handlers/chebi.R")
source("R/handlers/lipidmaps.R")
# source("R/handlers/kegg.R")
# source("R/handlers/chemspider.R")
# source("R/handlers/pubchem.R")
# source("R/handlers/metlin.R")


get_handler <- function (db_tag) {
  if (db_tag == "chebi_id") {
    return(ChebiHandler())
  } else if (db_tag == "hmdb_id") {
    return(HmdbHandler())
  } else if (db_tag == "lipidmaps_id") {
    return(LipidmapsHandler())
  }

  # database is not supported by this package:
  return(NULL)
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

transform_df <- function (df){
  attrs <- names(df)
  df2 <- data.frame(matrix(ncol = length(attrs), nrow = 1))
  colnames(df2) <- attrs

  for (attr in attrs) {
    if(is.na(df[[attr]][[1]])) {
      df2[[attr]] <- list(vector(length=0))
    } else {
      df2[[attr]] <- list(df[[attr]])
    }
  }

  return(df2)
}

resolve.options <- list(
  suppress = FALSE,
  open_connection = TRUE
)

resolve_single_id <- function(start_db_tag, start_db_id) {
  'Discover from single database ID'
  #start_db_tag <- paste(c(start_db_tag, '_id'), collapse="")

  # Create initial dataframe from user input:
  df.res <- create_empty_record()
  df.res[[start_db_tag]][[1]] <- start_db_id

  # call the resolve algorithm
  df.res <- resolve(df.res)

  return(df.res)
}

resolve <- function(df.discovered) {
  'Discover missing IDs and attributes from a dataframe input'
  if (is.null(df.discovered)) {
    stop("Dataframe was nor provided for resolve_from_queue")
  }

  # transform data.frame to have lists instead of vectors
  df.discovered <- transform_df(df.discovered)

  if (resolve.options$open_connection) {
    print("Opening DB connection...")
    db.connect()
  }

  # queue for the discover algorithm
  Q <- Queue()

  # put initial dataframe to queue
  for (attr in attr.refs) {
    # insert all reference IDs to the queue
    db_id <- df.discovered[[attr]][[1]]

    if (!is.null(db_id) && length(db_id) > 0 && !is.na(db_id)) {
      Q$push(tuple(attr, db_id, "root"))
    }
  }

  # downloads whole database
  discovered <- set()
  undiscovered <- set()

  # Keep getting IDs out of the queue while it's not empty
  while (Q$size() > 0) {
    tpl <- Q$pop()
    db_tag <- tpl[[1]]
    db_id <- tpl[[2]]
    # db_ref_origin <- tpl[[3]]

    hand <- get_handler(db_tag)

    if (is.null(hand)) {
      undiscovered <- c(undiscovered, tpl)
      next
    }

    # Query metabolite record from local database or web api
    if (!resolve.options$suppress)
      print(paste(c("Fetching:", db_tag, db_id), collapse=" "))
    df.result <- hand$query_metabolite(db_id)
    # attributes of common meta interface:
    # pubchem_id chebi_id kegg_id hmdb_id metlin_id lipidmaps_id cas_id
    # smiles inchi inchikey formula names mass

    if (is.null(df.result)) {
      # add to undiscovered set if not found
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

        # fos kod:
        # if (!is.na(old.val)) {
        #   df.discovered[[attr]][[1]] <- c(old.val, new.val)
        # } else {
        #   df.discovered[[attr]] <- list(vector(length = 0))
        #   new.val
        # }
      }
    }

    # parse reference IDs and add them to queue
    for (new_db_tag in attr.refs) {
      new_db_id <- df.result[[new_db_tag]][[1]]

      # check if such refId is present in the record
      if (!is.empty(new_db_id)) {
        if (!set_contains_element(discovered, tuple(new_db_tag, new_db_id))) {
          # enqueue for exploration, but only if it hasn't occured before
          # Format: (db_tag, db_id, db_tag that referenced this id)
          Q$push(tuple(new_db_tag, new_db_id, db_tag))
        }
      }
    }
  }

  if (resolve.options$open_connection) {
    print("Closing DB connection...")
    db.disconnect()
  }

  # filter out redundant vectors & replace logical(0) with NA
  for (attr in names(df.discovered)) {
    if (length(df.discovered[[attr]][[1]]) == 0)
      df.discovered[[attr]][[1]] <- NA
    else
      df.discovered[[attr]][[1]] <- unique(df.discovered[[attr]][[1]])
  }

  return(df.discovered)
}

