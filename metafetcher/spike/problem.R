library(stringi)
library(stringr)


oof = c('5-Oxoasdfsd "2b" aglycone', 'asdage')

join_sql_arr <- function(v) {
  v <- str_replace_all(str_replace_all(v, "'", ''), '"', '')

  return(paste0('{"', paste(v, collapse = '","'), '"}'))
}


join_sql_arr(oof)


grepl('"', oof, fixed = TRUE)
apply()
