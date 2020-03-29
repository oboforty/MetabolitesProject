library(httr)
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
  st <- paste0('{"', paste(v, collapse = '","'), '"}')
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

create_empty_record <- function (n=1) {
  df <- data.frame(matrix(ncol = length(attr.meta), nrow = n))
  colnames(df) <- attr.meta

  return(df)
}

transform_df <- function (df) {
  L <- nrow(df)
  attrs <- names(df)
  df2 <- data.frame(matrix(ncol = length(attrs), nrow = L))
  colnames(df2) <- attrs

  for (attr in attrs) {
    df2[[attr]] <- list(vector(length=0))
  }

  idx <- !is.na(df)
  df2[idx] <- df[idx]

  return(df2)
}

revert_df <- function (df) {
  for (attr in names(df)) {
    df[[attr]] <- unlist(lapply(df[[attr]], join))
  }

  return(df)
}

http_call_api <- function (url, db_id) {
  out <- tryCatch({
    r <- GET(sprintf(url,db_id), timeout(resolve.options$http_timeout))

    if (r$status != 200)
      return (NULL)
    return(content(r))
  },
  error=function(cond) {
    print(sprintf("HTTP timeout: %s %s", url, db_id))
    return(NULL)
  })

  if (is.null(out))
    return(NULL)
  return(out)
}
