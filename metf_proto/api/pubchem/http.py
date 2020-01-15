import requests

from api import http_log


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
