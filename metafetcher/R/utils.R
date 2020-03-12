library(stringr)

null2na <- function(v) {
  if (is.null(v))
    return(NA)
  else
    return(v)
}

is.empty <- function(v) {
  # + is.null(v)
  return(length(v) == 0 || is.na(v) || v == "" || v == "\n")
}


lstrip <- function(sr, sub) {
  return(substring(sr, nchar(sub)+1, nchar(sr)))
}

join <- function(v) {
  st <- paste(c('{"',paste(v, collapse = '","'),'"}'), collapse="")

  return(st)
}

pg_vector2str <- function (m) {
  # todo: later
}

pg_str2vector <- function (x) {
  # return found groups of "anystring"
  pattern <- "\"(.+?)\""
  m <- str_match_all(x, pattern)[[1]][,2]

  # if there was no match, then the x string itself is already a word
  if (length(m) == 0)
    return(substr(x, 2, nchar(x)-1))

  # find single words in the rest of the unmatched string
  pattern2 <- "[a-zA-Z0-9_-]+"
  m <- c(m, str_match_all(paste(str_split(x, pattern)[[1]], collapse=""), pattern2)[[1]])

  return(m)
}


mod<-function(x,m) {
  t1<-floor(x/m)
  return(x-t1*m)
}



create_empty_record <- function () {
  df <- data.frame(matrix(ncol = length(attr.meta), nrow = 1))
  colnames(df) <- attr.meta

  return(df)
}

transform_df <- function (df){
  attrs <- names(df)
  df2 <- data.frame(matrix(ncol = length(attrs), nrow = 1))
  colnames(df2) <- attrs

  for (attr in attrs) {
    if (is.na(df[[1, attr]])) {
      df2[[attr]] <- list(vector(length=0))
    } else {
      df2[[attr]] <- list(df[[attr]])
    }
  }

  return(df2)
}
