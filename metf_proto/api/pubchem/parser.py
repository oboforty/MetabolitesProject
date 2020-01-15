from api.utils import DBs


def parse_PubChem(db_id, c):
    content, cont_refs = c
    dataPUBCHEM = {"refs": {}, "refs_etc": {}, "data": {}, 'names': []}


    # parse xrefs:
    INF = cont_refs['InformationList']['Information'][0]
    for db_tag, db_id in zip(INF['SourceName'], INF['RegistryID']):
        db_tag = db_tag.lower()

        if db_tag == 'human metabolome database (hmdb)':
            db_tag = 'hmdb'

        if db_tag in DBs:
            dataPUBCHEM['refs'][db_tag] = db_id
        else:
            dataPUBCHEM['refs_etc'][db_tag] = db_id

    # parse name:
    INF = content['PC_Compounds'][0]['props']

    for q in INF:
        # discover names in this weird json
        if 'name' in q['urn']['label'].lower():
            name = q['value']['sval']
            dataPUBCHEM['names'].append(name)

    dataPUBCHEM['data'] = content

    return dataPUBCHEM
