import requests

from metf_proto2.db_imp.FetcherBase import FetcherBase


class FetcherHMDB(FetcherBase):
    def __init__(self):
        super().__init__(
            url_get='http://www.hmdb.ca/metabolites/{}.xml',
            url_all='http://www.hmdb.ca/system/downloads/current/hmdb_metabolites.zip'
        )

    def parse(self, db_id, content):
        """Parses custom content"""
        pass

    def parse_db(self, filename):
        """Parses custom content"""
        pass


