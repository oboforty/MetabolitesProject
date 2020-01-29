library(XML2R)



filepath <- "../tmp/hmdb_metabolites.xml"



doit <- function() {

  doc <- xml2::read_xml(filepath)

  nodeset <- doc %>% xml2::xml_children()
  L <- length(nodeset)

  for (i in 1:L) {
    data <- xmlParse(nodeset[[i]])

    metaboliteName <- as.character(xpathApply(data,"/metabolite/name", xmlValue))

    if (mod(i, 5000) == 0) {
      print(i)
    }
  }
}

print("STARTED")
start_time <- Sys.time()

doit()

print("FINISHED")
end_time <- Sys.time()
print(round(end_time - start_time,2))

