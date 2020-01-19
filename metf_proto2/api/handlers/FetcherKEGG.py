from time import time

from api import ctx
from api.localdb import Metabolite
from api.utils import download_file
from metf_proto2.api.handlers.FetcherBase import FetcherBase


class FetcherKEGG(FetcherBase):
    def __init__(self, fake=False):
        super().__init__(
            url_get='{}',
            url_all='',
            fake=fake
        )

    def parse(self, db_id, content) -> Metabolite:
        meta = Metabolite()
        return meta

    def download_all(self):
        path_fn = 'tmp/'
        t1 = time()

        if not self.fake:
            download_file(self.url_all_tpl, path_fn)

        session = ctx.Session()

        # save parsed entries into database
        print("Parsing HMDB finished! Took {} seconds".format(round(time() - t1, 2)))
        session.commit()
        session.close()
