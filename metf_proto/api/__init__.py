from api.hmdb.http import *
from api.hmdb.http import *
from api.chebi.http import *
from api.kegg.http import *
from api.pubchem.http import *
from api.lipidmaps.http import *
from api.chemspider.http import *
from api.metlin.http import *

from api.hmdb.fake import *
from api.hmdb.fake import *
from api.chebi.fake import *
from api.kegg.fake import *
from api.pubchem.fake import *
from api.lipidmaps.fake import *
from api.chemspider.fake import *
from api.metlin.fake import *

from api.hmdb.parser import *
from api.hmdb.parser import *
from api.chebi.parser import *
from api.kegg.parser import *
from api.pubchem.parser import *
from api.lipidmaps.parser import *
from api.chemspider.parser import *
from api.metlin.parser import *

fake_http = False


class DbProxy:
    def __init__(self, fetcher, parser):
        self.fetch = fetcher
        self.parse = parser


if fake_http:
    proxy_db = {
        'hmdb': DbProxy(fake_HMDB, parse_HMDB),
        'chebi': DbProxy(fake_ChEBI, parse_ChEBI),
        'kegg': DbProxy(fake_KEGG, parse_KEGG),
        'pubchem': DbProxy(fake_PubChem, parse_PubChem),
        'lipidmaps': DbProxy(fake_Lipidmaps, parse_Lipidmaps),
        'chemspider': DbProxy(fake_ChemSpider, parse_ChemSpider),
        'metlin': DbProxy(fake_Metlin, parse_Metlin),
    }
else:
    proxy_db = {
        'hmdb': DbProxy(call_HMDB, parse_HMDB),
        'chebi': DbProxy(call_ChEBI, parse_ChEBI),
        'kegg': DbProxy(call_KEGG, parse_KEGG),
        'pubchem': DbProxy(call_PubChem, parse_PubChem),
        'lipidmaps': DbProxy(call_Lipidmaps, parse_Lipidmaps),
        'chemspider': DbProxy(call_ChemSpider, parse_ChemSpider),
        'metlin': DbProxy(call_Metlin, parse_Metlin),
    }


def call_api(db_tag, db_id):
    prx = proxy_db[db_tag]
    result = prx.fetch(db_id)

    if result is None:
        return None

    return prx.parse(db_id, result)
