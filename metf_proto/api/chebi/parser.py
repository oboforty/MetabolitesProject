import xmltodict


def parse_ChEBI(db_id, content):
    cont = dict(xmltodict.parse(content))
    x = cont['S:Envelope']['S:Body']['getCompleteEntityResponse']['return']

    names = [x.pop('chebiAsciiName')]
    names.extend([synx['data'] for synx in x.pop('Synonyms')])

    dataCHEBI = {"refs": {}, "refs_etc": {}, "data": {}, 'names': names}

    # add DatabaseLinks as refs
    dblinks = x.pop('DatabaseLinks')
    for oof in dblinks:
        db_tag = oof['type'].lower()
        db_id = oof['data']

        if 'kegg' in db_tag:
            dataCHEBI['refs']['kegg'] = db_id
            # todo: discover other Chebi xrefs
        else:
            dataCHEBI['refs_etc'][db_tag] = db_id

    dataCHEBI['data'] = dict(x)

    return dataCHEBI
