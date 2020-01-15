

def fake_ChemSpider(db_id):
    try:
        with open('api/chemspider/data/{}.json'.format(db_id)) as fh:
            content = fh.read()
        with open('api/chemspider/data/{}_refs.json'.format(db_id)) as fh:
            cont_refs = fh.read()
    except FileNotFoundError:
        return None

    return content, cont_refs
