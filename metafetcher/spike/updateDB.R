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
library(hmdbQuery)
#install_github("processVISION", "muschellij2")
devtools::install_github("muschellij2/processVISION")
library("processVISION")
#library("muschellij2")
library('XML2R')
#devtools::install_github('dantonnoriega/xmltools')
library(xmltools)
library(data.table)
library('RMySQL')
library('readr')




fileHMDB<- "hmdb_metabolites.xml"

#Create Data frame with all IDS
createDB(fileHMDB,"")
createDB=function(fileHMDB,pathCHEBI)
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
  metaboliteDB=matrix(nrow=length(nodeset),ncol=5)
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
  
  CHEBI_DB=readCHEBI(fileCHEBI)
 return(metaboliteDB)
} 

readCHEBI=function(fileCHEBIpath)
{
  
  mydb = dbConnect(MySQL(), user='root', password='Qazx@2418015', host='localhost')
  dbSendQuery(mydb, "CREATE DATABASE CHEBI;")
  
  dbSendQuery(mydb, "USE CHEBI")
  
  createMySqlDB("MySQLDump/generic_dumps/mysql_create_tables.sql")
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/compounds.sql")
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/chemical_data.sql")  
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/comments.sql")
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/database_accession.sql")
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/names.sql")
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/ontology.sql")
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/references.sql")
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/vertice.sql")
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/relation.sql")
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/structures.sql")
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/default_structures.sql")
  createMySqlDB("MySQLDump/generic_dumps/generic_dump_allstar/autogen_structures.sql")
  
  }





 
 
 
createMySqlDB<- function(filepath){
  #filepath="/Users/sarayones/Desktop/Projects/MetabolitesProject/MetabolitesProject/MySQLDump/generic_dumps/generic_dump_allstar/chemical_data.sql" 
  con = file(filepath, "r")
    
   sql.string <- ""
   
   while (TRUE){
     line=readLines(con, n = 1,encoding="UTF-8")
     sql.string<- paste(sql.string, line)
     
     if(length(line)!=0)
     {
       if(grepl("#",line))
       { sql.string=""
         next
       }
     while(!grepl(";",line))
     {
       line <- readLines(con, n = 1,encoding="UTF-8")
       sql.string <- paste(sql.string, line)
       print("hello")
     }
       df <- dbSendQuery(mydb,sql.string)
       sql.string=""
       
     }else
       {
       break
     }
     
       }
   
   close(con)
 
 }
 
 
 
 
 