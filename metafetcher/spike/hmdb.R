library(XML)
library(iterators)


filepath <- "../../tmp/hmdb_metabolites.xml"


parse_metabolite <- function(x) {

}

store <- function() {
  print("Store", df)
}


parse_xml_iter(filepath, parse_metabolite, store)

# fileConn<-file("snoop_dog.xml")
# writeLines(x, fileConn)
# close(fileConn)
