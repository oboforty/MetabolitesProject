source("https://bioconductor.org/biocLite.R")
biocLite("hmdbQuery")
library("XML")
library("methods")
library(xmltools)
library(magrittr)
library(plyr)
library(rvest)
library(purrr)
library(dplyr)
require(devtools)
install_github("processVISION", "muschellij2")
library("processVISION")
library("muschellij2")
library('XML2R')
devtools::install_github('dantonnoriega/xmltools')
library(xmltools)



file <- "hmdb_metabolites.xml"

doc <- xml2::read_xml(file)

nodeset <- doc %>%
  xml2::xml_children()
length(nodeset) # lots of nodes!
nodeset[1] %>% # lets look at ONE node's tree
  xml_view_tree()

data=xmlParse(nodeset[[1]])
xpathApply(data,"/metabolite/smiles",xmlValue)
xpathApply(data,"/metabolite/secondary_accessions/accession",xmlValue)

fileHMDB<- "hmdb_metabolites.xml"


#Create Data frame with all IDS
createDB=function(fileHMDB,fileCHEBI)
{
  
  #Read fileHMDB
  doc <- xml2::read_xml(fileHMDB)
  
  nodeset <- doc %>%
    xml2::xml_children()
  
  #Create A dataframe with IDS from HMDB file
  metaboliteName=NULL
  PrimaryHMDB_ID=NULL
  SecondryHMDB_ID=NULL
  CHEBI_ID=NULL
  smiles=NULL
  data=NULL
  metaboliteDB=matrix(,nrow=length(nodeset),ncol=5)
  colnames(metaboliteDB)<-c("metaboliteName","PrimaryHMDB_ID","SecondryHMDB_ID","CHEBI_ID","smiles")
  
  for (i in 1:length(nodeset))
  {
    
    data=xmlParse(nodeset[[i]])
    metaboliteDB[i,"metaboliteName"]=as.character(xpathApply(data,"/metabolite/name",xmlValue))
    metaboliteDB[i,"PrimaryHMDB_ID"]=as.character(xpathApply(data,"/metabolite/accession",xmlValue))
    metaboliteDB[i,"SecondryHMDB_ID"]=paste(unlist(xpathApply(data,"/metabolite/secondary_accessions/accession",xmlValue)),collapse="|")
    metaboliteDB[i,"CHEBI_ID"]=as.character(xpathApply(data,"/metabolite/chebi_id",xmlValue))
    metaboliteDB[i,"smiles"]=as.character(xpathApply(data,"/metabolite/smiles",xmlValue))
    #  metaboliteDB=rbind(metaboliteDB,data.frame(metaboliteName,PrimaryHMDB_ID,SecondryHMDB_ID,CHEBI_ID,smiles))
    
    
  }
  
  
} 











terminal_paths <- nodeset[1] %>%
  xml_get_paths(only_terminal_parent = TRUE)

terminal_xpaths <- terminal_paths %>% ## collapse xpaths to unique only
  unlist() %>%
  unique()

ldply(xmlToList(nodeset[1]), data.frame)
map(xml_attrs) %>% 
  map_df(~as.list(.))


terminal_nodesets <- lapply(terminal_xpaths, xml2::xml_find_all, x = doc) # use xml docs, not nodesets! I think this is because it searches the 'root'.
df2 <- terminal_nodesets %>%
  purrr::map(xml_dig_df) %>%
  purrr::map(dplyr::bind_rows) %>%
  dplyr::bind_cols() %>%
  dplyr::mutate_all(empty_as_na)
df2

df1 <- lapply(terminal_xpaths, xml_to_df, file = file, is_xml = FALSE, dig = FALSE) %>%
  dplyr::bind_cols()
df1

terminal_paths <- nodeset[1] %>%
  xml_get_paths(only_terminal_parent = TRUE)

terminal_xpaths <- terminal_paths %>% ## collapse xpaths to unique only
  unlist() %>%
  unique()

library(rvest)
library(dplyr)

pg <- read_html("https://en.wikipedia.org/wiki/Main_Page")
links <- html_nodes(pg, "a")

hello=bind_rows(lapply(xml_attrs(nodeset[[1]]), function(x) data.frame(as.list(x), stringsAsFactors=FALSE)))


hello=xmlToDF("hmdb_metabolites.xml", xpath = "/metabolite/accession", isXML = FALSE)

if (!isXML) 
  doc = xmlParse(doc)
#### get the records for that form
nodeset <- getNodeSet(doc, xpath)

## get the field names
var.names <- lapply(nodeset, names)

## get the total fields that are in any record
fields = unique(unlist(var.names))

## extract the values from all fields
dl = lapply(fields, function(x) {
  if (verbose) 
    print(paste0("  ", x))
  xpathSApply(proc, paste0(xpath, "/", x), xmlValue)
})

## make logical matrix whether each record had that field
name.mat = t(sapply(var.names, function(x) fields %in% x))
df = data.frame(matrix(NA, nrow = nrow(name.mat), ncol = ncol(name.mat)))
names(df) = fields

## fill in that data.frame
for (icol in 1:ncol(name.mat)) {
  rep.rows = name.mat[, icol]
  if (usewhich) 
    rep.rows = which(rep.rows)
  df[rep.rows, icol] = dl[[icol]]
}



xmlDoc <- "hmdb_metabolites.xml"
result <- NULL

#function to use with xmlEventParse
row.sax = function() {
  ROW = function(node){
    children <- xmlChildren(node)
    children[which(names(children) == "text")] <- NULL
    result <<- rbind(result, sapply(children,xmlValue))
  }
  branches <- list(ROW = ROW)
  return(branches)
}

#call the xmlEventParse
xmlEventParse(xmlDoc, handlers = list(), branches = row.sax(),
              saxVersion = 2, trim = FALSE)

#and here is your data.frame
result <- as.data.frame(result, stringsAsFactors = F)


doc <- "hmdb_metabolites.xml"

d = xmlRoot(doc)
size = xmlSize(d)

names = NULL
for(i in 1:size){
  v = getChildrenStrings(d[[i]])
  names = unique(c(names, names(v)))
}

for(i in 1:size){
  v = getChildrenStrings(d[[i]])
  cat(paste(v[names], collapse=","), "\n", file="a.csv", append=TRUE)
}

m = data.table(matrix(NA,nc=length(names), nr=size))
setnames(m, names)
for (n in names) mode(m[[n]]) = "character"
for(i in 1:size){
  v = getChildrenStrings(d[[i]])
  m[i, names(v):= as.list(v), with=FALSE]
}
for (n in names) m[, n:= type.convert(m[[n]], as.is=TRUE), with=FALSE]


readCHEBI=function(fileCHEBI)
{
  
  
  # compounds<-as.data.frame(fread("Flat_file_tab_delimited/compounds.tsv"))
  #  compounds=compounds[,c("ID","NAME","DEFINITION","STAR")]
  #  comments<-as.data.frame(fread("Flat_file_tab_delimited/comments.tsv"))
  #  comments=comments[,c("COMPOUND_ID","TEXT")]
  #  chemical_data<-as.data.frame(fread("Flat_file_tab_delimited/chemical_data.tsv"))
  # chemical_data=comments[,c("COMPOUND_ID","TYPE","CHEMICAL_DATA")]
  # database_accession=as.data.frame(fread("Flat_file_tab_delimited/database_accession.tsv"))
  # chemical_data=comments[,c("COMPOUND_ID","TYPE","CHEMICAL_DATA")]
  # temp=NULL
  # temp=compounds[match(comments[,"COMPOUND_ID"],compounds[,"ID"]),]
  # ind<-apply(X2, 1, function(x) all(is.na(x)))
  # ind<-apply(comments[match(compounds[,"ID"],comments[,2]),], 1, function(x) all(is.na(x)))
  #X2=X2[!ind,]
  #temp=cbind(temp,comments)
  ##temp=temp[,which( names(temp) %in% c("ID","NAME","DEFINITION","STAR","COMPOUND_ID","TEXT") )]
  ##temp2=chemical_data[match(temp[,"COMPOUND_ID"],chemical_data[,"COMPOUND_ID"]),]
  #temp=merge(temp, chemical_data, by="COMPOUND_ID", all.x = TRUE)
  #temp=merge(temp, database_accession, by="COMPOUND_ID", all.x = TRUE)
  #View(ddply(temp,"TYPE.x",numcolwise(paste)))
  
  #View(aggregate(temp['TYPE.x'],by=temp['COMPOUND_ID'],FUN=paste))
  #View(aggregate(temp['TYPE'],by= temp['COMPOUND_ID'] ,FUN=paste))
  
  
  
  
}


mydb = dbConnect(MySQL(), user='root', password='Qazx@2418015', host='localhost', dbname="CHEBI")
hello=dbSendQuery(mydb,"LOAD DATA INFILE 'Flat_file_tab_delimited/compounds.tsv' INTO TABLE compounds;")

df <- dbGetQuery(mydb, statement = read_file('/Users/sarayones/Desktop/Projects/MetabolitesProject/MetabolitesProject/MySQLDump/generic_dumps/mysql_create_tables.sql'))

sqlstring=getSQL("/Users/sarayones/Desktop/Projects/MetabolitesProject/MetabolitesProject/MySQLDump/generic_dumps/trial.sql")

hello=paste(readLines("/Users/sarayones/Desktop/Projects/MetabolitesProject/MetabolitesProject/MySQLDump/generic_dumps/trial.sql"), collapse = "")

statement = read_file('/Users/sarayones/Desktop/Projects/MetabolitesProject/MetabolitesProject/MySQLDump/generic_dumps/trial.sql')

df <- dbSendQuery(mydb,sqlstring)

data = fetch(df, n=-1)



getSQL <- function(filepath){
  filepath="/Users/sarayones/Desktop/Projects/MetabolitesProject/MetabolitesProject/MySQLDump/generic_dumps/trial.sql"
  con = file(filepath, "r")
  sql.string <- ""
  
  while (TRUE){
    line <- readLines(con, n = 1,encoding="UTF-8")
    
    if ( length(line) == 0 ){
      break
    }
    
    line <- gsub("\\n", " ", line)
    
    if(grepl("#",line) == TRUE){
      line <- paste(sub("#","/*",line),"*/")
    }
    
    sql.string <- paste(sql.string, line)
  }
  
  close(con)
  return(sql.string)
}

