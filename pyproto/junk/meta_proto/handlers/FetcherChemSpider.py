from time import time

from pyproto import ctx
from pyproto.utils import download_file
from .FetcherBase import FetcherBase


def call_ChemSpider(db_id):

    url = 'https://api.rsc.org/compounds/v1/records/{}/details?fields=SMILES,Formula,InChI,InChIKey,StdInChI,StdInChIKey,AverageMass,MolecularWeight,MonoisotopicMass,NominalMass,CommonName,ReferenceCount,DataSourceCount,PubMedCount,RSCCount,Mol2D,Mol3D'.format(db_id)
    r = requests.get(url = url)
    url = 'https://api.rsc.org/compounds/v1/records/{}/externalreferences'.format(db_id)
    r2 = requests.get(url = url)

    http_log(r)
    http_log(r2)

    if not r.content or not r2.content:
        return None

    return r.content.decode('utf-8'), r2.content.decode('utf-8')

def parse_ChemSpider(db_id, c):
    content = json.loads(c[0])
    cont_refs = json.loads(c[1])

    dataSPIDER = {"refs": {}, "refs_etc": {}, "data": {}, 'names': []}

    dataSPIDER['names'] = content.pop('commonName')
    dataSPIDER['data'] = content

    # x refs:
    for xref in cont_refs['externalReferences']:
        db_tag = xref['source'].lower()
        db_id = xref['externalId']

        if 'human metabolome database' == db_tag:
            db_tag = 'hmdb'

        if db_tag in DBs:
            dataSPIDER['refs'][db_tag] = db_id
        else:
            dataSPIDER['refs_etc'][db_tag] = db_id

    return dataSPIDER

class FetcherChemSpider(FetcherBase):
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
