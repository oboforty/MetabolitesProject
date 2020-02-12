library(parallel)
library(MASS)
library(foreach)
library(doParallel)

#starts <- rep(100, 40)
#fx <- function(nstart) kmeans(Boston, 4, nstart=nstart)
numCores <- detectCores()

registerDoParallel(numCores)




mylist <- list()

now <- function() {
  return(as.numeric(Sys.time()))
}


foreach (i=1:4) %do% {

  if (i == 1) {
    # Main core

    print("Main started")
    for (n in 1:100000) {
      # enqueue
      mylist <- c(mylist, n)
    }
    print("Main Exited")
  } else {
    print("Thread started")
    #t0 <- now()

    print("Thread exited")
  }
}

