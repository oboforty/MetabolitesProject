from abc import abstractmethod, ABCMeta

import requests

from ..utils import download_file


class FetcherBase(metaclass=ABCMeta):

    def __init__(self, url_get, url_all, fake=False):
        self.url_get_tpl = url_get
        self.url_all_tpl = url_all
        self.fake = fake

    def get_metabolite(self, db_id):
        # check local database
        en = self.query_metabolite(db_id)

        if en is None:
            if self.fake:
                result = self._fake_it(db_id)
            else:
                result = self.download_metabolite(db_id)

            en = self.parse(db_id, result)

        return en

    def download_metabolite(self, db_id):
        """Gets one entry
        By default it initiates a single HTTP call
        """
        r = requests.get(url=self.url_get_tpl.format(db_id))
        #http_log(r)

        if r.status_code == 404 or not r.content:
            return None
        return r.content.decode('utf-8')

    def query_metabolite(self, db_id):
        """Gets one entry from local db
        By default it just accesses the core table
        """

        # todo: access table with id/names/refs/refetc

        # Todo: translate to common view Metabolite class
        return None

    @abstractmethod
    def download_all(self):
        """Downloads whole metabolite database"""
        ...

    @abstractmethod
    def parse(self, db_id, content):
        """Parses custom db content"""
        ...

    def _fake_it(self, db_id):
        filename = 'data/fakes/hmdb/{}.xml'.format(db_id)

        try:
            with open(filename) as fh:
                content = fh.read()
        except FileNotFoundError:
            return None

        return content
