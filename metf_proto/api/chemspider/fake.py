import json


def fake_ChemSpider(db_id):
    try:
        with open('api/chemspider/data/{}.json'.format(db_id)) as fh:
            content = json.load(fh)
        with open('api/chemspider/data/{}_refs.json'.format(db_id)) as fh:
            cont_refs = json.load(fh)
    except FileNotFoundError:
        return None

    return (content, cont_refs)
