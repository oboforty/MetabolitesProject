import json
from collections import defaultdict

from pyproto.utils import parse_iter_sdf, rlen

path_fn = '../../tmp/ChEBI_complete.sdf'

i = 0
card_SDF = defaultdict(int)
count_SDF = defaultdict(int)
nchar = defaultdict(int)

duplicates = set()


with open('hmdb_secondary.json', 'r') as fh:
    idmap = json.load(fh)
idmap_inv = defaultdict(set)

for k,v in idmap.items():
    idmap_inv[v].add(k)

N_secondary = 0
N_has_secondary = 0
N_primary = 0

foreign = set()


for me in parse_iter_sdf(path_fn):
    if 'KEGG COMPOUND Database Links' in me:
        kegg = me['KEGG COMPOUND Database Links']

        if isinstance(kegg, list):
            for k in kegg:
                foreign.add(('kegg', k))
        else:
            foreign.add(('kegg', kegg))

    if 'LIPID MAPS instance Database Links' in me:
        lipidmaps = me['LIPID MAPS instance Database Links']

        if isinstance(lipidmaps, list):
            for k in lipidmaps:
                foreign.add(('lipidmaps', k))
        else:
            foreign.add(('lipidmaps', lipidmaps))

    if 'Chemspider Database Links' in me:
        chemspider = me['Chemspider Database Links']

        if isinstance(chemspider, list):
            for k in chemspider:
                foreign.add(('chemspider', k))
        else:
            foreign.add(('chemspider', chemspider))
    #if 'PubChem Database Links' in me:
    #    foreign.add(('pubchem', me['
    if 'HMDB Database Links' in me:
        # check if referenced HMDB_ID is primary or secondary:
        hmdb_id = me.get('HMDB Database Links')

        if isinstance(hmdb_id, list):
            for k in hmdb_id:
                foreign.add(('hmdb_id', k))
        else:
            foreign.add(('hmdb_id', hmdb_id))


        if isinstance(hmdb_id, list):
            N_secondary += len(hmdb_id)
        else:
            N_secondary += 1
        N_has_secondary += 1
    N_primary += 1

    for attr, val in me.items():
        c = rlen(val)
        if c > card_SDF[attr]:
            card_SDF[attr] = c

        if c > 1:
            # mark multiple cardinalities, see if they're duplicates
            duplicates.add(tuple(val))

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

print("CHEBI SDF")
print(N_primary, N_has_secondary, N_secondary)
print(dict(card_SDF))
print(dict(count_SDF))
print(dict(nchar))
print(len(foreign))

#url = 'https://www.ebi.ac.uk/webservices/chebi/2.0/test/getCompleteEntity?chebiId={}'

#for dup in duplicates:
#    r = requests.get(url = url.format())
