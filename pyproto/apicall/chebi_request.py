from collections import defaultdict
import requests
from pyproto.utils import DBs
import xmltodict




def parse_chebi(db_id, content):
    data = {}
    refs = defaultdict(list)


    cont = dict(xmltodict.parse(content))
    x = cont['S:Envelope']['S:Body']['getCompleteEntityResponse']['return']


    # add DatabaseLinks as refs
    for oof in x.pop('DatabaseLinks'):
        db_tag = oof['type'].lower()
        db_id = oof['data']

        if 'kegg' in db_tag:
            refs['kegg'].append(db_id)
        else:
            refs[db_tag].append(db_id)

    # todo: add data from x
    data = dict(x)
    names = [x.get('chebiAsciiName')]

    return data, refs


db_id = '138560'
r = requests.get(url = 'https://www.ebi.ac.uk/webservices/chebi/2.0/test/getCompleteEntity?chebiId={}'.format(db_id))

if r.content is not None:
    data, refs = parse_chebi(db_id, r.content.decode('utf-8'))

    print(data)
