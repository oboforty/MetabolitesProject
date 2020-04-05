library(sets)
source("R/queue.R")
source("R/utils.R")

source("R/handlers/hmdb.R")
source("R/handlers/chebi.R")
source("R/handlers/kegg.R")
source("R/handlers/lipidmaps.R")
source("R/handlers/pubchem.R")
# source("R/handlers/chemspider.R")
# source("R/handlers/metlin.R")


db_handlers <- list(
  chebi_id = ChebiHandler$new(),
  hmdb_id = HmdbHandler$new(),
  lipidmaps_id = LipidmapsHandler$new(),
  kegg_id = KeggHandler$new(),
  pubchem_id = PubchemHandler$new()
)

attr.refs <- names(db_handlers)
# + metlin_id, cas_id, chemspider_id

attr.meta <- c(
    attr.refs,
    "inchi", "inchikey", "smiles",
    "names", "formula",
    "mass", "monoisotopic_mass"
)

resolve.options <- list(
  suppress = FALSE,
  open_connection = TRUE,
  http_timeout = 3
)


resolve_single_id <- function(start_db_tag, start_db_id) {
  'Discover from single database ID'
  #start_db_tag <- paste(c(start_db_tag, '_id'), collapse="")

  # Create initial dataframe from user input:
  df.res <- create_empty_record(1, attr.meta)
  df.res[[1, start_db_tag]] <- start_db_id

  # call the resolve algorithm
  df.res <- resolve(df.res)

  return(df.res)
}

resolve <- function(df.discovered) {
  'Discover missing IDs and attributes from a dataframe input'

  # transform data.frame to have lists instead of vectors
  df.discovered <- transform_df(df.discovered)

  if (resolve.options$open_connection) {
    print("Opening DB connection...")
    db.connect()
  }

  # queue for the discover algorithm
  L <- nrow(df.discovered)

  for (i in 1:L) {
    # variables for algorithm: Queue, discovered,
    Q <- Queue()
    discovered <- set()
    undiscovered <- set()
    secondary.ids <- set()

    if (!resolve.options$suppress) {
      print("-------------------------------")
      print(sprintf("Resolving #%s", i))
    }

    # put initial db ids to queue
    for (attr in attr.refs) {
      # insert all reference IDs to the queue
      db_id <- df.discovered[[i, attr]]

      if (!is.empty(db_id)) {
        Q$push(tuple(attr, db_id, "root"))
      }
    }


    while (Q$size() > 0) {
      # Keep getting IDs out of the queue while it's not empty
      tpl <- Q$pop()
      db_tag <- tpl[[1]]
      db_id <- tpl[[2]]

      hand <- db_handlers[[db_tag]]

      if (is.null(hand)) {
        # unknown database type
        undiscovered <- c(undiscovered, tpl)
        next
      }

      # Query metabolite record from local database or web api
      if (!resolve.options$suppress) {
        db_ref <- tpl[[3]]
        print(sprintf("%s -> %s (%s)", db_ref, db_tag, db_id))
      }
      df.result <- hand$query_metabolite(db_id)

      if (is.null(df.result)) {
        # 1.: check if we get a hit treating 'db_id' as a secondary id
        db_id_primary <- find_by_secondary_id(db_tag, db_id)

        if (!is.null(db_id_primary)) {
          # put the primary ID in the queue again to be resolved
          Q$push(tuple(db_tag, db_id_primary, sprintf("secondary_%s", db_tag)))

          # exclude secondary ids from output dataframe
          ids <- df.discovered[[i, db_tag]]
          df.discovered[[i, db_tag]] <- ids[ids != db_id]

          # and add it to a special list
          secondary.ids <- c(secondary.ids, tuple(db_tag, db_id))
          next
        }

        # none of the fallback strategies have worked, mark as 'undiscovered'
        undiscovered <- c(undiscovered, tpl)
        next
      }

      discovered <- c(discovered, tuple(db_tag, db_id))

      # merge result with previously discovered data
      for (attr in attr.meta) {
        new.val <- df.result[[1, attr]]
        old.val <- df.discovered[[i, attr]]

        if (!is.empty(new.val)) {
          df.discovered[[i, attr]] <- c(old.val, new.val)
        }
      }

      # parse reference IDs and add them to queue
      for (new_db_tag in attr.refs) {
        new_db_id <- df.result[[1, new_db_tag]]

        # check if such refId is present in the record
        if (!is.empty(new_db_id)) {
          if (!set_contains_element(discovered, tuple(new_db_tag, new_db_id))) {
            # enqueue for exploration, but only if it hasn't occured before
            # Format: (db_tag, db_id, db_tag that referenced this id)
            Q$push(tuple(new_db_tag, new_db_id, db_tag))
          }
        }
      }

      # todo: if we have all db ids, skip reverse query
      # todo: only run the reverse query once??!? maybe not
      if (Q$size() == 0) {
        # once we ran out of ids to explore, try reverse queries
        for (db_tag_missing in attr.refs) {

          if (length(df.discovered[[i, db_tag_missing]]) == 0) {
            # if (!resolve.options$suppress)
            #   print(sprintf("Reverse-querying: %s", db_tag_missing))

            # this db reference is still NA... try querying in reverse
            hand <- db_handlers[[db_tag_missing]]
            db_ids <- hand$query_reverse(df.discovered)

            for (db_id_missing in db_ids) {
              # put these newly discovered ids to the queue
              if (!set_contains_element(discovered, tuple(db_tag_missing, db_id_missing))) {
                Q$push(tuple(db_tag_missing, db_id_missing, "reversed"))
              }
            }
          }
        }
      }
    }
  }

  if (resolve.options$open_connection) {
    print("Closing DB connection...")
    db.disconnect()
  }

  # post parse data
  for (i in 1:L) {
    for (attr in names(df.discovered)) {
      val <- df.discovered[[i, attr]]

      # filter out redundant vectors & replace logical(0) with NA
      if (length(val) == 0)
        df.discovered[[i, attr]] <- NA
      else
        df.discovered[[i, attr]] <- unique(val)
    }
  }

  # Return complex output of everything
  return(list(
    df = df.discovered,

    discovered = lapply(discovered, as.vector),
    undiscovered = lapply(undiscovered, as.vector),
    secondary = lapply(secondary.ids, as.vector)
  ))
}

find_by_secondary_id <- function(db_tag, db_id) {
  # resolve primary id from 'db_id' as secondary id
  SQL2 <- "SELECT primary_id FROM secondary_id
    WHERE db_tag = '%s' AND secondary_id = '%s'"
  df.second <- db.query(sprintf(SQL2, db_tag, db_id))

  if (length(df.second) > 0 && !is.empty(df.second$primary_id[[1]])) {
    db_id1 <- df.second$primary_id[[1]]
    if (!resolve.options$suppress)
      print(sprintf("Resolved secondary %s id: %s > %s", db_tag, db_id, db_id1))

    return(db_id1)
  }

  return(NULL)
}
