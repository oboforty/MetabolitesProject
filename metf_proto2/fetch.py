from datetime import datetime
from time import time

from api import discover
from api.utils import get_http_log



def log(result, undiscovered, foreign, dt):

    LOG_OUT = ''

    LOG_OUT += "MetaFetcher - " + str(datetime.now()) + " - took {} seconds".format(dt)
    LOG_OUT += "\nDiscovered entries: {}\n".format(len(result))
    for db_tag, dct in result.items():
        if dct:
            LOG_OUT += "    {}({})\n".format(db_tag, dct['id'])
    LOG_OUT += '\n\n'

    LOG_OUT += "Undiscovered entries: {}\n".format(len(undiscovered))
    for db_tag, db_id, db_tag_from in undiscovered:
        LOG_OUT += "    {}({})  -- from {}, \n".format(db_tag, db_id, db_tag_from)
    LOG_OUT += '\n\n'

    LOG_OUT += "Foreign entries: {}\n".format(len(foreign))
    for db_tag, db_id, db_tag_from in foreign:
        LOG_OUT += "    {}({})  -- from {}, \n".format(db_tag, db_id, db_tag_from)
    LOG_OUT += '\n\n'

    with open('logs/log_{}.txt'.format(time()), 'w') as fh:
        fh.write(LOG_OUT)

    # http log
    with open('logs/http_{}.txt'.format(time()), 'w') as fh:
        fh.write(get_http_log())


def main():
    t1 = time()
    result, undiscovered, foreign = discover('hmdb', 'HMDB0001134')
    t2 = time()

    # log discovered & http
    #log(result, undiscovered, foreign, round(t2 - t1, 2))

    print("FETCH finished, took {}s".format(round(t2-t1, 3)))
    print("Discovered: {}, Undiscovered: {}, Foreign: {}".format(len(result), len(undiscovered), len(foreign)))

if __name__ == "__main__":
    main()
