
def fake_KEGG(db_id):
    try:
        with open('api/kegg/data/{}.txt'.format(db_id)) as fh:
            content = fh.readlines()
    except FileNotFoundError:
        return None

    return content
