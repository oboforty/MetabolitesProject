from collections import defaultdict

from api.utils import parse_iter_sdf, rlen

path_fn = '../tmp/hmdb_structures.sdf'

i = 0
card_SDF = defaultdict(int)


for me in parse_iter_sdf(path_fn):

    for attr, val in me.items():
        c = rlen(val)
        if c > card_SDF[attr]:
            card_SDF[attr] = c

    i += 1
    if i % 5000 == 0:
        print(i)

print("HMDB SDF")
print(dict(card_SDF))
