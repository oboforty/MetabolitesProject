import requests

from api.utils import http_log


def call_HMDB(db_id):
    url = 'http://www.hmdb.ca/metabolites/{}.xml'.format(db_id)
    r = requests.get(url = url)
    http_log(r)

    if not r.content:
        return None

    if r.status_code == 404:
        # HMDB returns an error XML instead of an empty string
        return None

    return r.content.decode('utf-8')
