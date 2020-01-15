import queue

import pandas
import numpy as np

from fakeapi import proxy_db

_DBs = ['hmdb', 'kegg', 'chebi', 'chemspider', 'pubchem', 'metlin']


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
    for db_tag in _DBs:
        #_data[db_tag+'_id'] = np.array([])
        _data[db_tag] = {}

    # queue for the discover algorithm
    Q = queue.SimpleQueue()
    Q.put((start_db_tag, start_db_id))

    # discover other metabolites from other DBs
    while Q.qsize() > 0:
        db_tag, db_id = Q.get()

        # "HTTP call"
        result = proxy_db[db_tag](db_id)

        if result is None:
            #print("  !Foreign ID not found:", db_tag, db_id)
            undiscovered.add((db_tag, db_id))
            continue

        result['id'] = db_id
        _data[db_tag] = result
        #_data[db_tag+'_id'].append(db_id)
        discovered.add((db_tag, db_id))

        # discover foreign refs from this entry:
        for ref_tag_prefix, ref_db_id in result['refs'].items():
            ref_db_tag = ref_tag_prefix[0:-3]

            # not supported DB type, skip:
            if ref_db_tag not in _DBs:
                foreign.add((ref_db_tag, ref_db_id))
                continue

            if (ref_db_tag, ref_db_id) not in discovered:
                if _nil(ref_db_id):
                    if bool(ref_db_id):
                        print("  !Malformed {}_id: '{}'".format(db_tag, ref_db_id))
                    continue

                # schedule this foreign ID for discovery
                Q.put((ref_db_tag, ref_db_id) )

    # validate consensus regarding ref ids:

    return _data, undiscovered, foreign



def main():
    result, undiscovered, foreign = discover('hmdb', 'HMDB0001134')

    print("FETCH finished: ", len(result))
    for db_tag, dct in result.items():
        if dct:
            print("{}({})".format(db_tag, dct['id']), end=', ')
    print('\n---------------------')

    print("Undiscovered entries: ")
    for db_tag, db_id in undiscovered:
        print("{}({})".format(db_tag, db_id), end=', ')
    print('\n---------------------')

    print("Foreign entries: ")
    for db_tag, db_id in foreign:
        print("{}({})".format(db_tag, db_id), end=', ')
    print('\n---------------------')





if __name__ == "__main__":
    main()
