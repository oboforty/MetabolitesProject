import requests

from api import http_log


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
