from fakeapi import call_HMDB, call_ChEBI, call_KEGG, call_PubChem, call_Lipidmaps, call_ChemSpider, call_Metlin

fake_http = True

if fake_http:
    proxy_db = {
        'hmdb': call_HMDB,
        'chebi': call_ChEBI,
        'kegg': call_KEGG,
        'pubchem': call_PubChem,
        'lipidmaps': call_Lipidmaps,
        'chemspider': call_ChemSpider,
        'metlin': call_Metlin,
    }
else:
    proxy_db = {

    }

    raise Exception("HTTP calls are not yet accepted")


def call_api(db_tag, db_id):
    return proxy_db[db_tag](db_id)
