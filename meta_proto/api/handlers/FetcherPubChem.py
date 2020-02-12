from time import time

from api import ctx
from api.utils import download_file
from api.handlers.FetcherBase import FetcherBase


def call_PubChem(db_id):

    url = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{}/json'.format(db_id)
    r = requests.get(url = url)
    url = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{}/xrefs/SourceName,RegistryID/JSON'.format(db_id)
    r2 = requests.get(url = url)
    http_log(r)
    http_log(r2)

    if not r.content or not r2.content:
        return None

    return r.content.decode('utf-8'), r2.content.decode('utf-8')

def parse_PubChem(db_id, c):
    content = json.loads(c[0])
    cont_refs = json.loads(c[1])
    dataPUBCHEM = {"refs": {}, "refs_etc": {}, "data": {}, 'names': []}


    # parse xrefs:
    INF = cont_refs['InformationList']['Information'][0]
    for db_tag, db_id in zip(INF['SourceName'], INF['RegistryID']):
        db_tag = db_tag.lower()

        if db_tag == 'human metabolome database (hmdb)':
            db_tag = 'hmdb'

        if db_tag in DBs:
            dataPUBCHEM['refs'][db_tag] = db_id
        else:
            dataPUBCHEM['refs_etc'][db_tag] = db_id

    # parse name:
    INF = content['PC_Compounds'][0]['props']

    for q in INF:
        # discover names in this weird json
        if 'name' in q['urn']['label'].lower():
            name = q['value']['sval']
            dataPUBCHEM['names'].append(name)

    dataPUBCHEM['data'] = content

    return dataPUBCHEM

class FetcherPubChem(FetcherBase):
    def __init__(self, fake=False):
        super().__init__(
            url_get='{}',
            url_all='',
            fake=fake
        )

    def parse(self, db_id, content):
        meta = Metabolite()
        return meta

    def download_all(self):
        path_fn = 'tmp/'
        t1 = time()

        if not self.fake:
            download_file(self.url_all_tpl, path_fn)

        session = ctx.Session()

        # save parsed entries into database
        print("Parsing HMDB finished! Took {} seconds".format(round(time() - t1, 2)))
        session.commit()
        session.close()
