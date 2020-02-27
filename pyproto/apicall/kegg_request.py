from collections import defaultdict

import requests

from pyproto.utils import DBs


def parse_KEGG(db_id, content):
    content = content.split('\n')
    dataKEGG = defaultdict(list)
    refsKEGG = defaultdict(list)
    handle = iter(content)

    # smart guess whitespace from 1st line
    line = next(handle)
    try:
        FL = line.index(db_id.upper())
    except:
        return None, None

    state = None
    for line in handle:
        if line.startswith('///') or line == '':
            # /// skips idk
            continue

        if not line.startswith("   "):
            # interpret labels as regular lines, but save the label
            state = line.split()[0]
            line = line[FL:].rstrip('\n')
        else:
            line = line.lstrip().rstrip('\n')

        if 'ENTRY' == state:
            print(line)
        elif 'DBLINKS' == state:
            # foreign references:
            db_tag, ref_ids = line.split(': ')

            if db_tag.endswith('_id'):
                db_tag = db_tag[:-3]
            db_tag = db_tag.lower()

            for db_id in ref_ids.split(" "):
                refsKEGG[db_tag].append(db_id)
        else:
            dataKEGG[state].append(line)
            # todo: parse rest of file
            pass

    return dataKEGG, refsKEGG


if __name__ == "__main__":
    db_id = 'C21604'
    #db_id = 'C21417'
    r = requests.get(url = 'http://rest.kegg.jp/get/cpd:{}'.format(db_id))

    if r.content is not None:
        data, refs = parse_KEGG(db_id, r.content.decode('utf-8'))

        print(data)
