import json
from collections import defaultdict

from pyproto.utils import parse_iter_sdf, rlen

path_fn = '../../tmp/lipidmaps.sdf'

i = 0
card_SDF = defaultdict(int)
count_SDF = defaultdict(int)



with open('hmdb_secondary.json', 'r') as fh:
    idmap = json.load(fh)
idmap_inv = defaultdict(set)

for k,v in idmap.items():
    idmap_inv[v].add(k)

N_secondary = 0
N_primary = 0
N_none = 0
nchar = defaultdict(int)



for me in parse_iter_sdf(path_fn):

    if 'HMDB_ID' in me:
        # check if referenced HMDB_ID is primary or secondary:
        hmdb_id = me['HMDB_ID']

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
            #duplicates.add(tuple(val))
            count_SDF[attr] += 1

        if isinstance(val, str):
            nc = len(val)
        else:
            nc = max([len(f) for f in val])
        if nc > nchar[attr]:
            nchar[attr] = nc

    i += 1
    if i % 5000 == 0:
        print(i)

print("LipidMaps SDF")
print(N_primary, N_secondary, N_none)
print(dict(card_SDF))
print(dict(count_SDF))
print(dict(nchar))

