
DBs = ['hmdb', 'kegg', 'chebi', 'chemspider', 'pubchem', 'metlin']

LOG = ''


def http_log(r, _id=None):
    global LOG
    LOG += "  {} GET {}\n    {}\n\n".format(r.status_code, r.url, r.content)


def get_http_log():
    global LOG

    f = str(LOG)
    LOG = ''

    return f
