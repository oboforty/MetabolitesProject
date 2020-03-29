
file_i <- '../tmp/tests/resolve_i.RDS'

last_i <- readRDS(file_i)

last_i <- 5000

saveRDS(last_i, file_i)
