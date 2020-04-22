source("R/db_ctx.R")
source("R/utils.R")

oof = '{"5-Oxoasdfsd \"\"2b\"\" aglycone"}'

f =  db.query(sprintf('UPDATE "VARKOMAROM" SET var = \'%s\' WHERE pid = 1', postgresqlEscapeStrings(db_conn, oof)))

print(f)

db.disconnect()
