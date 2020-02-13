import json
from collections import defaultdict
import xmltodict
import xml.etree.ElementTree as ET

from api.utils import parse_xml_recursive, rlen

path_fn = '../tmp/hmdb_metabolites.xml'


# parse XML file:
context = ET.iterparse(path_fn, events=("start", "end"))
context = iter(context)

ev_1, xroot = next(context)
i = 0

card_XML = defaultdict(int)
idmap = {}



while True:
    try:
        ev_2, xmeta = next(context)

        i += 1

        me = parse_xml_recursive(context)

        if isinstance(me, str):
            break

        if me['secondary_accessions']:
            try:
                if isinstance(me['secondary_accessions'], str):
                    idmap[me['secondary_accessions']] = me['accession']
                elif me['secondary_accessions']['accession']:
                    if isinstance(me['secondary_accessions']['accession'], str):
                        idmap[me['secondary_accessions']['accession']] = me['accession']
                    else:
                        for sec in me['secondary_accessions']['accession']:
                            idmap[sec] = me['accession']
            except Exception as e:
                print(e)
                break

        for attr, val in me.items():
            if not isinstance(val, str):
                if attr == 'synonyms':
                    val = val['synonym']
                elif attr == 'secondary_accessions':
                    val = val['accession']

            c = rlen(val)
            if c > card_XML[attr]:
                card_XML[attr] = c



        if i % 5000 == 0:
            print(i)

    except StopIteration:
        break

print("HMDB XML")
print(dict(card_XML))

with open('hmdb_secondary.json', 'w') as fh:
    json.dump(dict(idmap), fh)
