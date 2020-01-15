import xmltodict


def parse_HMDB(db_id, content):
    v = dict(xmltodict.parse(content))['metabolite']

    names = [v.pop('name')]
    names.extend(v.pop('synonyms')['synonym'])

    dataHMDB = {"refs": {
        "hmdb": v.pop('accession'),
        "kegg": v.pop('kegg_id'),
        "chebi": v.pop('chebi_id'),
        "chemspider": v.pop('chemspider_id'),
        "pubchem": v.pop('pubchem_compound_id'),
        "metlin": v.pop('metlin_id'),
        # todo: no lipidmaps?
    }, "refs_etc": {
        # todo: What to do with these:
        "drugbank": v.pop('drugbank_id'),
        "wikipedia": v.pop('wikipedia_id'),
        "phenol_explorer_compound": v.pop('phenol_explorer_compound_id'),
        "foodb": v.pop('foodb_id'),
        "knapsack": v.pop('knapsack_id'),
        "biocyc": v.pop('biocyc_id'),
        "bigg": v.pop('bigg_id'),
        "pdb": v.pop('pdb_id'),
    }, 'data': v, 'names': names}


    return dataHMDB
