import requests

from api import http_log


def call_KEGG(db_id):
    url = 'http://rest.kegg.jp/get/cpd:{}'.format(db_id)
    r = requests.get(url = url)
    http_log(r)

    if not r.content:
        return None

    return r.content.decode('utf-8').split('\n')
