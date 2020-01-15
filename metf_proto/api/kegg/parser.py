from api.utils import DBs


def parse_KEGG(db_id, content: list):
    dataKEGG = {"refs": {}, "refs_etc": {}, "data": {}, 'names': []}
    handle = iter(content)

    # smart guess whitespace from 1st line
    line = next(handle)
    FL = line.index(db_id.upper())

    state = None
    for line in handle:
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
            db_tag, db_id = line.split(': ')
            db_tag = db_tag.lower()

            if db_tag.endswith('_id'):
                db_tag = db_tag[:-3]

            if db_tag in DBs:
                dataKEGG['refs'][db_tag] = db_id
            else:
                dataKEGG['refs_etc'][db_tag] = db_id
        elif 'NAME' == state:
            dataKEGG['names'].append(line)
        else:
            # todo: parse rest of file
            pass

    return dataKEGG
