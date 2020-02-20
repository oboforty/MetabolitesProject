source("R/db_ctx.R")
source("R/utils.R")
source('R/discover.R')


do_coverage_test <- function (db_tag, records) {
  resolved <- list(
    chebi_id = 0,
    hmdb_id = 0,
    lipidmaps_id = 0,
    kegg_id = 0,
    pubchem_id = 0
  )
  unresolved <- list(
    chebi_id = 0,
    hmdb_id = 0,
    lipidmaps_id = 0,
    kegg_id = 0,
    pubchem_id = 0
  )
  duplicates <- list(
    chebi_id = 0,
    hmdb_id = 0,
    lipidmaps_id = 0,
    kegg_id = 0,
    pubchem_id = 0
  )
  total <- 0

  resolve.options$suppress <<- TRUE
  resolve.options$open_connection <<- FALSE

  i <- 0
  start_time <- Sys.time()
  db.connect()

  for (db_id in records[[db_tag]]) {
    df.res <- resolve_single_id(db_tag, db_id)
    i <- i + 1

    for (attr in names(resolved)) {
      v <- df.res[[attr]][[1]]

      if (length(v) != 0 && !is.na(v)) {
        if (length(v) == 1) {
          resolved[[attr]] <- resolved[[attr]] + 1
        } else {
          duplicates[[attr]] <- duplicates[[attr]] + 1
        }
      } else {
        unresolved[[attr]] <- unresolved[[attr]] + 1
      }
    }

    #if (mod(i, 5000) == 0) {
    #  log <- paste(c(i, round(as.numeric(Sys.time() - start_time),2), "seconds"), collapse=" ")
    #  print(log)
    #}
  }
  db.disconnect()


  total <- i
  print(paste(c("Total:", total), collapse=" "))
  print(paste(c("Took", round(as.numeric(Sys.time() - start_time),2), "seconds"), collapse=" "))
  print("-------------------")

  for (attr in names(resolved)) {
    print(attr)
    print(paste(c("Resolved:", (100*resolved[[attr]]/total), "%"), collapse=" "))
    print(paste(c("Unresolved:", (100*unresolved[[attr]]/total), "%"), collapse=" "))
    print(paste(c("Duplicates:", (100*duplicates[[attr]]/total), "%"), collapse=" "))
    print("-------------------")
  }
}



# complete coverage test
db <- 'hmdb'
db_tag <- paste(c(db,'_id'),collapse="")


records <- db.query(paste(c("SELECT ",db,"_id FROM ",db,"_data LIMIT 100"), collapse = ""))
do_coverage_test(db_tag, records)

