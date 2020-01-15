

def fake_PubChem(db_id):
    try:
        with open('api/pubchem/data/{}.json'.format(db_id)) as fh:
            content = fh.read()
        with open('api/pubchem/data/{}_refs.json'.format(db_id)) as fh:
            cont_refs = fh.read()
    except FileNotFoundError:
        return None

    return content, cont_refs
