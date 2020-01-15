
def fake_ChEBI(db_id):
    filename = 'api/chebi/data/{}.xml'.format(db_id)

    try:
        with open(filename) as fh:
            content = fh.read()
    except FileNotFoundError:
        return None

    return content
