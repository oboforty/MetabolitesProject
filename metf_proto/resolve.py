import queue
from datetime import datetime
from time import time

from api import call_api, DBs


#import pandas
#import numpy as np
from api.utils import get_http_log


def _nil(var):
    if not bool(var):
        return True
    # accounts for xml newlines, whitespace & etc
    s = var.strip().replace('\r', '').replace('\n', '')
    return not bool(s)


def discover(start_db_tag, start_db_id):
    discovered = set()
    undiscovered = set()
    foreign = set()

    _data = {}

    # create empty "data frame"
    for db_tag in DBs:
        #_data[db_tag+'_id'] = np.array([])
        _data[db_tag] = {}

    # queue for the discover algorithm
    Q = queue.SimpleQueue()
    Q.put((start_db_tag, start_db_id, 'root'))

    # discover other metabolites from other DBs
    while Q.qsize() > 0:
        db_tag, db_id, db_ref_origin = Q.get()

        # "HTTP call"
        result = call_api(db_tag, db_id)

        if result is None:
            #print("  !Foreign ID not found:", db_tag, db_id)
            undiscovered.add((db_tag, db_id, db_ref_origin))
            continue

        result['id'] = db_id
        _data[db_tag] = result
        #_data[db_tag+'_id'].append(db_id)
        discovered.add((db_tag, db_id))

        foreign.update([(key, val, db_tag) for key,val in result['refs_etc'].items()])

        # discover foreign refs from this entry:
        for ref_db_tag, ref_db_id in result['refs'].items():

            # not supported DB type, skip:
            if ref_db_tag not in DBs:
                foreign.add((ref_db_tag, ref_db_id, db_tag))
                continue

            if (ref_db_tag, ref_db_id) not in discovered:
                if _nil(ref_db_id):
                    if bool(ref_db_id):
                        print("  !Malformed {}_id: '{}'".format(db_tag, ref_db_id))
                    continue

                # schedule this foreign ID for discovery
                Q.put((ref_db_tag, str(ref_db_id), db_tag) )

    # validate consensus regarding ref ids:

    return _data, undiscovered, foreign



def main():
    result, undiscovered, foreign = discover('hmdb', 'HMDB0001134')

    LOG_OUT = ''

    print("FETCH finished")
    print("Discovered: {}, Undiscovered: {}, Foreign: {}".format(len(result), len(undiscovered), len(foreign)))

    LOG_OUT += "MetaFetcher - " + str(datetime.now())
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


if __name__ == "__main__":
    main()
