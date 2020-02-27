from collections import defaultdict
import requests
from pyproto.utils import DBs
import xmltodict



def parse_hmdb(db_id, content):
    data = {}
    refs = defaultdict(list)
    names = []

    v = dict(xmltodict.parse(content))['metabolite']

    name = v.get('name')
    if name:
        names.append(name)

    synonyms = v.get('synonyms')
    if isinstance(synonyms, dict):
        names.extend(synonyms['synonym'])
    elif synonyms == '':
        pass
    else:
        print('??????')

    for attr, val in v.items():
        if attr[-3:] == '_id':
            refs[attr[:-3]].append(val)
        elif val is not None:
            data[attr] = val

    return data, refs


db_id = 'HMDB0001235'
r = requests.get(url = 'http://www.hmdb.ca/metabolites/{}.xml'.format(db_id))

if r.content is not None:
    data, refs = parse_hmdb(db_id, r.content.decode('utf-8'))

    print(data)
