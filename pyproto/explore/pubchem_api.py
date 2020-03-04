from collections import defaultdict
from random import choices

import requests

from pyproto import ctx
from pyproto.apicall.pubchem_request import parse_pubchem
from pyproto.utils import rlen

i = 0

card = defaultdict(int)
count = defaultdict(int)
nchar = defaultdict(int)

duplicates = set()



session = ctx.Session()
r = list(session.execute("SELECT pubchem_id FROM chebi_data WHERE pubchem_id IS NOT NULL LIMIT 800 OFFSET 4000"))


for i,row in enumerate(r):
    pubchem_id = row['pubchem_id']

    r = requests.get(url='https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{}/json'.format(pubchem_id))
    r2 = requests.get(url='https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{}/xrefs/SourceName,RegistryID/JSON'.format(pubchem_id))

    if r.content is not None:
        data, refs = parse_pubchem(pubchem_id, r.content.decode('utf-8'), r2.content.decode('utf-8'))

    i += 1

    if i % 10 == 100:
        print(i)

    if r.content is None:
        continue

    data, refs = parse_pubchem(pubchem_id, r.content.decode('utf-8'), r2.content.decode('utf-8'))

    if data is None or refs is None:
        continue

    for attr, val in list(data.items())+list(refs.items()):
        c = rlen(val)
        if c > card[attr]:
            card[attr] = c
        if c > 1:
            count[attr] += 1
        # if isinstance(val, str):
        #     nc = len(val)
        # elif not isinstance(val, float) and not isinstance(val, int):
        #     nc = max([len(f) for f in val])
        # if nc > nchar[attr]:
        #     nchar[attr] = nc

print("pubchem:")
print(dict(card))
print(dict(count))
print(dict(nchar))
