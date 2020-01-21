library(XML)
library(iterators)
require("RPostgreSQL")

# String buffer size
BL <- 1000

# Commit buffer size
BDFL <- 100

# the script commits to database after reaching this many bytes in the buffer
COMMIT_SIZE <- 4*1024*1024


parse_xml_iter <- function(filepath) {
  start_time <- Sys.time()

  n_parsed <- 0

  # read file line by line
  con <- file(filepath, "r")
  it <- ireadLines(con)

  # ignore first two lines
  nextElem(it)
  nextElem(it)

  # buffer for the XML parsing
  i <- 1
  buffer <- character(BL)
  xml <- ""

  # data frame buffer for the DB
  j <- 1
  vec_ids <- c(BDFL)
  vec_blob <- c(BDFL)
  buffer_size <- 0

  # connect to DB
  drv <- dbDriver("PostgreSQL")
  db_conn <- dbConnect(drv, dbname = "metafetcher", host = "localhost", port = 5432, user = "postgres", password = "postgres")

  repeat {
    line <- nextElem(it)
    buffer[i] <- line
    i <- i + 1

    if (i >= BL) {
      # empty buffer
      xml <- paste(xml, paste(buffer, collapse=''))
      i <- 1
    }
    else if (line == "</metabolite>") {
      xmlend <- paste(buffer[1:i-1], collapse='')
      xml <- paste(xml, xmlend, collapse='')

      i <- 1

      # parse xml
      tryCatch({
        x <- xmlToList(xmlParse(xml))
      }, error = function(e) {

        print("Error in XML. ")

        # todo: itt: dump file
      })


      # store raw XML in db buffer:
      vec_ids[j] <- x$accession
      vec_blob[j] <- xml

      # keep DF buffer
      j <- j + 1
      buffer_size <- buffer_size + nchar(xml)

      if (j >= BDFL || buffer_size >= COMMIT_SIZE) {
        # save DB buffer as dataframe
        df <- data.frame(hmdb_id=vec_ids, dxml=vec_blob)
        dbWriteTable(db_conn, "hmdb_data", value = df, append = TRUE, row.names = FALSE)

        # todo: save metabolites lookup table too

        print(paste("Inserting to DB... ", j))

        # reset db buffers
        vec_ids <- c(BDFL)
        vec_blob <- c(BDFL)
        j <- 1
        buffer_size <- 0
      }

      # clear buffer
      n_parsed <- n_parsed + 1
      xml = ""
    }
  }

  print("Closing DB & File")
  close(con)
  close(db_conn)


  end_time <- Sys.time()

}

hmdb <- function(fake = FALSE) {
  return(list(
    download_all = function() {
      filepath <- "tmp/hmdb_metabolites.xml"

      if (!fake) {
        # todo: download that large xml
      }

      # parse file iteratively (line by line)
      parse_xml_iter(filepath)
    },

    parse = function() {
      print("fake_metabolite hmdb")
    },

    download = function() {
      print("download hmdb")
    },

    fake = function() {
      print("fake hmdb")
    },

    query = function() {
      print("query hmdb")
    }
  ))
}
