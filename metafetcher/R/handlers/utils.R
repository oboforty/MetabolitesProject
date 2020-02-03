
null2na <- function(v) {
  if (is.null(v))
    return(NA)
  else
    return(v)
}

is.empty <- function(v) {
  return(is.null(v) || is.na(v) || v == "" || v == "\n")
}

lstrip <- function(sr, sub) {
  return(substring(sr, nchar(sub)+1, nchar(sr)))
}

join <- function(v) {
  st <- paste(c('{"',paste(v, collapse = '","'),'"}'), collapse="")

  return(st)
}

mod<-function(x,m) {
  t1<-floor(x/m)
  return(x-t1*m)
}
