from collections import defaultdict

from pyproto.utils import parse_iter_sdf, rlen

path_fn = '../../tmp/hmdb_structures.sdf'

i = 0
card_SDF = defaultdict(int)
count_SDF = defaultdict(int)
nchar = defaultdict(int)

duplicates = set()


for me in parse_iter_sdf(path_fn):

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
        print(dict(card_SDF))
        print(dict(count_SDF))

print("HMDB SDF")
print(dict(card_SDF))
