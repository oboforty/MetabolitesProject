import ftplib
from collections import defaultdict

url = 'ftp://ftp.ncbi.nlm.nih.gov/pubchem/Compound/CURRENT-Full/SDF/'

ftp = ftplib.FTP(url)

from api.utils import parse_iter_sdf, rlen

files = ftp.nlst()

for file in files:
    path_fn = '../tmp/pubchem/{}'.format(file)

    i = 0
    card_SDF = defaultdict(int)
    count_SDF = defaultdict(int)

    duplicates = set()


    for me in parse_iter_sdf(path_fn):

        for attr, val in me.items():
            c = rlen(val)
            if c > card_SDF[attr]:
                card_SDF[attr] = c

            if c > 1:
                # mark multiple cardinalities, see if they're duplicates
                #duplicates.add(tuple(val))
                count_SDF[attr] += 1

        i += 1
        if i % 5000 == 0:
            print(i)

    print("PubChem SDF")
    print(dict(card_SDF))
    print(dict(count_SDF))
