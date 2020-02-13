import json
from collections import defaultdict

import requests

from api.utils import parse_iter_sdf, rlen

path_fn = '../tmp/ChEBI_complete.sdf'

i = 0
card_SDF = defaultdict(int)
count_SDF = defaultdict(int)

duplicates = set()


with open('hmdb_secondary.json', 'r') as fh:
    idmap = json.load(fh)
idmap_inv = defaultdict(set)

for k,v in idmap.items():
    idmap_inv[v].add(k)

N_secondary = 0
N_primary = 0
N_none = 0

for me in parse_iter_sdf(path_fn):

    if 'HMDB Database Links' in me:
        # check if referenced HMDB_ID is primary or secondary:
        hmdb_id = me['HMDB Database Links']

        if not isinstance(hmdb_id, list):
            if hmdb_id in idmap:
                N_secondary += 1
            elif hmdb_id in idmap_inv:
                N_primary += 1
            else:
                N_none += 1

    for attr, val in me.items():
        c = rlen(val)
        if c > card_SDF[attr]:
            card_SDF[attr] = c

        if c > 1:
            # mark multiple cardinalities, see if they're duplicates
            duplicates.add(tuple(val))

            count_SDF[attr] += 1

    i += 1
    if i % 5000 == 0:
        print(i)

print("CHEBI SDF")
print(N_primary, N_secondary, N_none)
print(dict(card_SDF))
print(dict(count_SDF))

#url = 'https://www.ebi.ac.uk/webservices/chebi/2.0/test/getCompleteEntity?chebiId={}'

#for dup in duplicates:
#    r = requests.get(url = url.format())
