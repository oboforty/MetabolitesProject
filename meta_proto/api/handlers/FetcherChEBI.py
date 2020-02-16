import pandas as pd
import xmltodict

from pyproto import ctx
from pyproto.entities.metabolite import Metabolite
from .FetcherBase import FetcherBase


def los(v, f=None):
    if isinstance(v, list):
        if f is not None:
            return [f(e) for e in v]
        return v
    elif v is None:
        return None
    else:
        if f is not None:
            return f(v)
        return [v]



def call_ChEBI(db_id):
    url = 'https://www.ebi.ac.uk/webservices/chebi/2.0/test/getCompleteEntity?chebiId={}'.format(db_id)
    r = requests.get(url = url)
    http_log(r)

    if not r.content:
        return None

    return r.content.decode('utf-8')


class FetcherChEBI(FetcherBase):
    def __init__(self, fake=False):
        super().__init__(
            url_get='https://www.ebi.ac.uk/webservices/chebi/2.0/test/getCompleteEntity?chebiId={}',
            url_all='http://www.hmdb.ca/system/downloads/current/hmdb_metabolites',
            fake=fake
        )

    def query_metabolite(self, db_id):
        engine = ctx.get_engine()

        db_chebi = pd.read_sql("""SELECT chebi_id, names, 
            formulas, smiles, inchis, inchikeys, 
            cas_ids, kegg_ids, hmdb_ids, pubchem_ids, lipidmaps_ids
        FROM chebi_data WHERE chebi_id = '{}'""".format(db_id), con=engine)

        if db_chebi.size == 0:
            return None

        # Convert to common interface
        dif = {
            "source": "chebi",
            "names": db_chebi.names[0],
            "formulas": db_chebi.formulas[0],
            "smiles": db_chebi.smiles[0],
            "inchis": db_chebi.inchis[0],
            "inchikeys": db_chebi.inchikeys[0],

            "refs": {
                "lipidmaps": db_chebi.lipidmaps_ids[0],
                "chebi": [db_chebi.chebi_id[0]],
                "cas": db_chebi.cas_ids[0],
                "kegg": db_chebi.kegg_ids[0],
                "hmdb": db_chebi.hmdb_ids[0],
                "pubchem": db_chebi.pubchem_ids[0],
            }
        }

        return dif

    def parse(self, db_id, content):
        cont = dict(xmltodict.parse(content))
        x = cont['S:Envelope']['S:Body']['getCompleteEntityResponse']['return']

        names = [x.pop('chebiAsciiName')]
        names.extend()

        meta = Metabolite(names=names, source='chebi', refs_etc={})

        # add DatabaseLinks as refs
        dblinks = x.pop('DatabaseLinks')
        for oof in dblinks:
            db_tag = oof['type'].lower()
            db_id = oof['data']

            if 'kegg' in db_tag:
                setattr(meta, db_tag, db_id)
            else:
                meta.refs_etc[db_tag] = db_id

        # todo: add data from x

        return meta

    session = ctx.get_session()
