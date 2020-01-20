library(XML)
library(iterators)


hmdb <- function(fake = FALSE) {
  return(list(
    download_all = function() {
      filepath <- "tmp/hmdb_metabolites.xml"

      if (!fake) {
        # todo: download that large xml
      }

      # read file line by line
      con <- file(filepath, "r")
      it <- ireadLines(con)

      nextElem(it)
      xml_buffer <- ""

      while ( TRUE ) {
        line <- readLines(con, n = 1)

        if ( length(line) == 0 ) {
          break
        }


      }

      close(con)
      xml <- readChar(fn, file.info(fn)$size)


      x <- xmlToList(xmlParse(xml))


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
