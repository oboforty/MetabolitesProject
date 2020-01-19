from time import time

from api.chebi.http import call_ChEBI
from api.hmdb.http import call_HMDB
from performance import chebi, hmdb


def main():
    fh = open('logs/perform.txt', 'w')

    print("Requesting")
    t0 = time()
    try:
        for i,(db_tag, db_id) in enumerate(hmdb.rr):
            print("# {}...".format(i), end=" ")
            t1 = time()

            #content = call_ChEBI(db_id)
            content = call_HMDB(db_id)

            fh.write("{}({})  ->  {}\n".format(db_tag, db_id, bool(content)))

            t2 = time()
            print("took {} seconds".format(round(t2 - t1, 2)))
    except KeyboardInterrupt:
        pass

    fh.close()

    print("Overall took {} seconds".format(round(time() - t0, 2)))

if __name__ == "__main__":
    main()
