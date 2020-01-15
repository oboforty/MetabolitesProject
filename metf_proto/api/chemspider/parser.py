from api import DBs


def parse_ChemSpider(db_id, c):
    content, cont_refs = c

    dataSPIDER = {"refs": {}, "refs_etc": {}, "data": {}, 'names': []}

    dataSPIDER['names'] = content.pop('commonName')
    dataSPIDER['data'] = content

    # x refs:
    for xref in cont_refs['externalReferences']:
        db_tag = xref['source'].lower()
        db_id = xref['externalId']

        if 'human metabolome database' == db_tag:
            db_tag = 'hmdb'

        if db_tag in DBs:
            dataSPIDER['refs'][db_tag] = db_id
        else:
            dataSPIDER['refs_etc'][db_tag] = db_id

    return dataSPIDER