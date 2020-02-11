# MetabolitesProject

## Usage

To include the package you can do this (temporal solution, until we publish to CRAN). You can't find the package in CRAN yet.
```R
source('R/mf.R')
```

To begin the setup, you can download all the metabolite databases:

```R
download("chebi")
download("hmdb")
...
```
List of supported databases:
* hmdb
* chebi
* kegg
* pubchem
* metlin
* lipidmaps


To find the missing IDs for a single compound ID, use:
```R
discover("hmdb", "hmdb0000001")
```

However, you can use a dataframe of metabolite IDs as well. In case you provide more than a single ID per metabolite, make sure the IDs match and refer to each other (otherwise the algorithm will break and give you wrong results!)
```R
df_metas <- data.frame(
  hmdb=c("hmdb0000001", "hmdb0000001"),
  chebi=c(...),
  kegg=c(...),
  ...
)

find_missing(df_metas)
```
