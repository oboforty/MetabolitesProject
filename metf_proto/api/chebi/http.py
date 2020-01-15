import requests

from api import http_log


def call_ChEBI(db_id):
    url = 'https://www.ebi.ac.uk/webservices/chebi/2.0/test/getCompleteEntity?chebiId={}'.format(db_id)
    r = requests.get(url = url)
    http_log(r)

    if not r.content:
        return None

    return r.content.decode('utf-8')
