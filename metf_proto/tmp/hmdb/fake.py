

def fake_HMDB(db_id):
    filename = 'api/hmdb/data/{}.xml'.format(db_id)

    try:
        with open(filename) as fh:
            content = fh.read()
    except FileNotFoundError:
        return None

    return content
