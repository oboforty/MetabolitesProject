import queue

from .handlers.FetcherBase import FetcherBase
from .handlers.FetcherChEBI import FetcherChEBI
from .handlers.FetcherHMDB import FetcherHMDB

from pyproto.utils import _nil

proxy_db = {
    'hmdb': FetcherHMDB(fake=True),
    'chebi': FetcherChEBI(fake=True),
    # 'kegg': FetcherKEGG(fake=True),
    # 'pubchem': FetcherPubChem(fake=True),
    # 'chemspider': FetcherChemSpider(fake=True),
    # 'lipidmaps': FetcherLipidmaps(),
    # 'metlin': FetcherMetlin(),
}


def get_db(db_tag) -> FetcherBase:
    return proxy_db.get(db_tag)


DBs = list(proxy_db.keys())


def discover(start_db_tag, start_db_id):
    discovered = set()
    undiscovered = set()

    # foreign = set()
    #
    # _data = {}
    #
    # # create empty "data frame"
    # for db_tag in DBs:
    #     #_data[db_tag+'_id'] = np.array([])
    #     _data[db_tag] = {}

    # queue for the discover algorithm
    Q = queue.SimpleQueue()
    Q.put((start_db_tag, start_db_id, 'root'))

    dif = {
        "names": set(),
        "formulas": set(),
        "smiles": set(),
        "inchis": set(),
        "inchikeys": set(),

        "lipidmaps": set(),
        "chebi": set(),
        "cas": set(),
        "kegg": set(),
        "hmdb": set(),
        "pubchem": set(),
    }

    # discover other metabolites from other DBs
    while Q.qsize() > 0:
        db_tag, db_id, db_ref_origin = Q.get()

        # "HTTP call"
        db = get_db(db_tag)

        if db is not None:
            result = db.query_metabolite(db_id)
        else:
            result = None

        if result is None:
            #print("  !Foreign ID not found:", db_tag, db_id)
            undiscovered.add((db_tag, db_id, db_ref_origin))
            #print(db_tag, db_id, db_ref_origin, '    FAIL')
            continue

        discovered.add((db_tag, db_id))
        #print(db_tag, db_id, db_ref_origin, '    OK')

        # merge result to common view
        for attr in ["names", "formulas", "smiles", "inchis", "inchikeys"]:
            if attr in result:
                if isinstance(result[attr], list):
                    dif[attr].update(result[attr])
                elif result[attr] is not None:
                    dif[attr].add(result[attr])

        # parse references
        for ref_db_tag, db_ids in result['refs'].items():
            # merge references to the result
            if ref_db_tag in result['refs'] and result['refs'][ref_db_tag] is not None:
                dif[ref_db_tag].update(result['refs'][ref_db_tag])

            # put refs to the queue
            if db_ids is not None:
                for ref_db_id in db_ids:
                    if (ref_db_tag, ref_db_id) not in discovered:
                        if _nil(ref_db_id):
                            if bool(ref_db_id):
                                print("  !Malformed {}_id: '{}'".format(db_tag, ref_db_id))
                            continue

                        # schedule this foreign ID for discovery
                        Q.put((ref_db_tag, str(ref_db_id), db_tag) )

        # _data[db_tag] = result
        # #_data[db_tag+'_id'].append(db_id)
        #
        #
        # foreign.update([(key, val, db_tag) for key,val in result['refs_etc'].items()])
        #
        # # discover foreign refs from this entry:
        # for ref_db_tag, ref_db_id in result['refs'].items():
        #
        #     # not supported DB type, skip:
        #     if ref_db_tag not in DBs:
        #         foreign.add((ref_db_tag, ref_db_id, db_tag))
        #         continue
        #

    # validate consensus regarding ref ids:

    return dif, undiscovered
