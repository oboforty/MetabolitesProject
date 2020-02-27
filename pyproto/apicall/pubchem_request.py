import json
from collections import defaultdict

import requests

from pyproto.utils import DBs


def parse_pubchem(db_id, c0,c1):
    dataKEGG = defaultdict(list)
    refsKEGG = defaultdict(list)

    content = json.loads(c0)
    cont_refs = json.loads(c1)
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

    return dataPUBCHEM,9



db_id = '71362326'
r = requests.get(url='https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{}/json'.format(db_id))
r2 = requests.get(url='https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{}/xrefs/SourceName,RegistryID/JSON'.format(db_id))


if r.content is not None:
    data, refs = parse_pubchem(db_id, r.content.decode('utf-8'), r2.content.decode('utf-8'))

    print(data)

