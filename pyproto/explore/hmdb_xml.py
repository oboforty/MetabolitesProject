import json
from collections import defaultdict
import xml.etree.ElementTree as ET

from pyproto.utils import parse_xml_recursive, rlen

path_fn = '../../tmp/hmdb_metabolites.xml'


# parse XML file:
context = ET.iterparse(path_fn, events=("start", "end"))
context = iter(context)

ev_1, xroot = next(context)
i = 0

card_XML = defaultdict(int)
idmap = {}
count_SDF = defaultdict(int)
nchar = defaultdict(int)

duplicates = set()


N_secondary = 0
N_has_secondary = 0
N_has_secondary2 = 0
N_primary = 0


while True:
    try:
        ev_2, xmeta = next(context)

        i += 1

        me = parse_xml_recursive(context)

        if isinstance(me, str):
            break

        if me['secondary_accessions']:
            has_secondary = False

            try:
                if isinstance(me['secondary_accessions'], str):
                    idmap[me['secondary_accessions']] = me['accession']
                    N_secondary += 1

                    if not (len(me['secondary_accessions']) == 9 and me['secondary_accessions'][4:] == me['accession'][6:]):
                        has_secondary = True
                elif me['secondary_accessions']['accession']:
                    if isinstance(me['secondary_accessions']['accession'], str):
                        N_secondary += 1
                        idmap[me['secondary_accessions']['accession']] = me['accession']

                        if not (len(me['secondary_accessions']['accession']) == 9 and me['secondary_accessions']['accession'][4:] == me['accession'][6:]):
                            has_secondary = True

                    else:
                        for sec in me['secondary_accessions']['accession']:
                            idmap[sec] = me['accession']
                            N_secondary += 1

                            if not (len(sec) == 9 and sec[4:] == me['accession'][6:]):
                                has_secondary = True

            except Exception as e:
                print(e)
                break
            if has_secondary:
                N_has_secondary2 += 1
            N_has_secondary += 1
        N_primary += 1

        for attr, val in me.items():
            if not isinstance(val, str):
                if attr == 'synonyms':
                    val = val['synonym']
                elif attr == 'secondary_accessions':
                    val = val['accession']

            c = rlen(val)
            if c > card_XML[attr]:
                card_XML[attr] = c

            if c > 1:
                # mark multiple cardinalities, see if they're duplicates
                count_SDF[attr] += 1


        if i % 5000 == 0:
            print(i)

    except StopIteration:
        break

print("HMDB XML")
print(N_primary, N_secondary, N_has_secondary, N_has_secondary2)
print(dict(card_XML))
print(dict(count_SDF))

with open('hmdb_secondary.json', 'w') as fh:
    json.dump(dict(idmap), fh)
