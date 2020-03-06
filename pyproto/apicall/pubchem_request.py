import json
import re
from collections import defaultdict

import requests

from pyproto.utils import DBs


def parse_pubchem(db_id, c0,c1):
    dataKEGG = defaultdict(list)
    refsKEGG = defaultdict(list)

    content = json.loads(c0)
    cont_refs = json.loads(c1)

    # parse xrefs:

    INF = cont_refs['InformationList']['Information'][0]

    # todo: itt: smart guess IDs and insert
    for db_id in INF['RegistryID']:
        if db_id.startswith('CHEBI:'):
            db_tag = 'chebi_id'
        elif db_id.startswith('HMDB'):
            db_tag = 'hmdb'
        elif re.match('C\d{4,9}', db_id):
            db_tag = 'kegg_id'
        else:
            continue
        refsKEGG[db_tag].append(db_id)

    # for db_tag, db_id in zip(INF['SourceName'], INF['RegistryID']):
    #     db_tag = db_tag.lower()
    #
    #     if db_tag == 'human metabolome database (hmdb)':
    #         db_tag = 'hmdb'
    #
    #     refsKEGG[db_tag].append(db_id)

    dataKEGG.update(content['PC_Compounds'][0])
    props = dataKEGG.pop('props')


    for prop in props:
        label = prop['urn']['label']

        if label == 'InChI':
            dataKEGG['inchi'].append(prop['value']['sval'])
        elif label == 'InChIKey':
            dataKEGG['inchikeys'].append(prop['value']['sval'])
        elif label == 'SMILES':
            dataKEGG['smiles'].append(prop['value']['sval'])
        elif label == 'IUPAC Name':
            dataKEGG['names'].append(prop['value']['sval'])
        elif label == 'Molecular Formula':
            dataKEGG['formula'].append(prop['value']['sval'])
        elif label == 'Mass':
            dataKEGG['mass'].append(prop['value']['fval'])
        elif label == 'Molecular Weight':
            dataKEGG['weight'].append(prop['value']['fval'])
        elif label == 'Weight' and prop['urn']['name'] == 'MonoIsotopic':
            dataKEGG['monoisotopic'].append(prop['value']['fval'])
        elif label == 'Log P':
            dataKEGG['logp'].append(prop['value']['fval'])
        else:
            dataKEGG[label] = prop['value']


    return dataKEGG, refsKEGG



if __name__ == "__main__":
    db_id = '442306'
    r = requests.get(url='https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{}/json'.format(db_id))
    r2 = requests.get(url='https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{}/xrefs/SourceName,RegistryID/JSON'.format(db_id))


    if r.content is not None:
        data, refs = parse_pubchem(db_id, r.content.decode('utf-8'), r2.content.decode('utf-8'))

        print(refs)

