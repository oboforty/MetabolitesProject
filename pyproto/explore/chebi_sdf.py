from pyproto.utils import parse_iter_sdf, rlen

path_fn = '../../tmp/ChEBI_complete.sdf'

i = 0
v_card = []

for me in parse_iter_sdf(path_fn):
    attr = 'KEGG COMPOUND Database Links'

    if attr in me:
        if rlen(me[attr]) > 1:
            v_card.append(me[attr])

    i += 1
    if i % 5000 == 0:
        print(i)

print("CHEBI SDF")
print(v_card)
