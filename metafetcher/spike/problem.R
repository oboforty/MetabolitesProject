source("R/queue.R")
library(sets)

Q <- Queue()


Q$push(tuple("hmdb", "HMDB0000002", "root"))
Q$size()
v <- Q$pop()
Q$size()

f <- v[[1]]
