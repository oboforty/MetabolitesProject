from abc import ABC, abstractmethod

import requests

from metf_proto2.db_imp.utils import download_file


class FetcherBase(metaclass=ABC):

    def __init__(self, url_get, url_all):
        self.url_get_tpl = url_get
        self.url_all_tpl = url_all

    def get(self, db_id):
        # check local database
        en = self.get_metabolite(db_id)

        if en is None:
            result = self.download_metabolite(db_id)

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

    def download_all(self):
        """Downloads whole metabolite database"""
        try:
            download_file(self.url_all_tpl, 'tmp/{}'.format(self.url_all_tpl))
        except:
            raise Exception("Metabolite DB dump not found")
        #http_log(r)

        return True

    def get_metabolite(self, db_id):
        """Gets one entry from local db
        By default it just accesses the core table
        """

        # todo: access table with id/names/refs/refetc
        return None

    @abstractmethod
    def parse(self, db_id, content):
        """Parses custom db content"""
        ...

    @abstractmethod
    def parse_db(self, filename):
        """Parses whole database dump"""
        ...
