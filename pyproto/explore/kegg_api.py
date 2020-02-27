from collections import defaultdict
from random import choices

import requests

from pyproto import ctx
from pyproto.apicall.kegg_request import parse_KEGG
from pyproto.utils import rlen

i = 0

card = defaultdict(int)
count = defaultdict(int)
nchar = defaultdict(int)

duplicates = set()



session = ctx.Session()
r = list(session.execute("SELECT kegg_id FROM chebi_data WHERE kegg_id IS NOT NULL LIMIT 4000 OFFSET 5000"))


for i,row in enumerate(r):
    kegg_id = row['kegg_id']
    r = requests.get(url='http://rest.kegg.jp/get/cpd:{}'.format(kegg_id))

    i += 1

    if i % 100 ==0:
        print(i)

    if r.content is None:
        continue

    data, refs = parse_KEGG(kegg_id, r.content.decode('utf-8'))

    if data is None or refs is None:
        continue

    for attr, val in list(data.items())+list(refs.items()):
        c = rlen(val)
        if c > card[attr]:
            card[attr] = c
        if c > 1:
            count[attr] += 1
        if isinstance(val, str):
            nc = len(val)
        else:
            nc = max([len(f) for f in val])
        if nc > nchar[attr]:
            nchar[attr] = nc

print("kegg:")
print(dict(card))
print(dict(count))
print(dict(nchar))
