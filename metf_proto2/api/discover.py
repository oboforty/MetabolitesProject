import queue

from .handlers.FetcherBase import FetcherBase
from .handlers.FetcherChEBI import FetcherChEBI
from .handlers.FetcherChemSpider import FetcherChemSpider
from .handlers.FetcherHMDB import FetcherHMDB
from .handlers.FetcherKEGG import FetcherKEGG
from .handlers.FetcherPubChem import FetcherPubChem

from .utils import _nil

proxy_db = {
    'hmdb': FetcherHMDB(fake=True),
    'chebi': FetcherChEBI(fake=True),
    'kegg': FetcherKEGG(fake=True),
    'pubchem': FetcherPubChem(fake=True),
    'chemspider': FetcherChemSpider(fake=True),
    # 'lipidmaps': FetcherLipidmaps(),
    # 'metlin': FetcherMetlin(),
}


def get_db(db_tag) -> FetcherBase:
    return proxy_db[db_tag]


DBs = list(proxy_db.keys())


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
        db = get_db(db_tag)
        result = db.get_metabolite(db_id)

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

