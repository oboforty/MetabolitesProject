import xml.etree.ElementTree as ET

from pyproto.utils import parse_xml_recursive, rlen

path_fn = '../../tmp/hmdb_metabolites.xml'

# parse XML file:
context = ET.iterparse(path_fn, events=("start", "end"))
context = iter(context)

ev_1, xroot = next(context)
i = 0

while True:
    try:
        ev_2, xmeta = next(context)

        i += 1

        me = parse_xml_recursive(context)
        if isinstance(me, str):
            break

        if me['accession'] == 'HMDB0007939':
            print(me)
            break

        if i % 5000 == 0:
            print(i)

    except StopIteration:
        break
