from time import time

import xmltodict

from .. import ctx
from entities.localdb import Metabolite
from ..utils import download_file_ftp, parse_iter_sdf
from .FetcherBase import FetcherBase


class FetcherChEBI(FetcherBase):
    def __init__(self, fake=False):
        super().__init__(
            url_get='{}',
            url_all='',
            fake=fake
        )

    def parse(self, db_id, content) -> Metabolite:
        cont = dict(xmltodict.parse(content))
        x = cont['S:Envelope']['S:Body']['getCompleteEntityResponse']['return']

        names = [x.pop('chebiAsciiName')]
        names.extend([synx['data'] for synx in x.pop('Synonyms')])

        meta = Metabolite(names=names, source='chebi', refs_etc={})

        # add DatabaseLinks as refs
        dblinks = x.pop('DatabaseLinks')
        for oof in dblinks:
            db_tag = oof['type'].lower()
            db_id = oof['data']

            if 'kegg' in db_tag:
                setattr(meta, db_tag, db_id)
            else:
                meta.refs_etc[db_tag] = db_id

        # todo: add data from x

        return meta

    def _parse_bulk_sdfdict(self, sdfdict):

        # Discover names:
        names = [sdfdict.pop('ChEBI Name')]
        syn = sdfdict.pop('Synonyms', None)
        if syn:
            if isinstance(syn, str):
                names.append(syn)
            else:
                names.extend(syn)

        meta = Metabolite(names=names, source='chebi', refs_etc={})

        # automatically discover refids:
        meta.chebi_id = sdfdict.pop('ChEBI ID')
        xref_tpl = ' Database Links'
        for _key in list(sdfdict.keys()):
            if _key is not None and _key.endswith(xref_tpl):
                db_tag = _key.rstrip(xref_tpl)
                db_id = sdfdict.pop(_key)

                if 'kegg' in db_tag:
                    setattr(meta, db_tag, db_id)
                else:
                    meta.refs_etc[db_tag] = db_id

        # todo: add SMILES, InChI, formulae

        # todo: add additional data

        return meta

    def download_all(self):
        path_fn = 'tmp/ChEBI_complete.sdf'
        t1 = time()

        if not self.fake:
            # todo: @later
            download_file_ftp()

        session = ctx.Session()
        i = 0

        for metasdf in parse_iter_sdf(path_fn):
            metabolite = self._parse_bulk_sdfdict(metasdf)

            session.add(metabolite)

            if i % 1000 == 0:
                print(i)
                session.commit()

            i += 1

        # save parsed entries into database
        print("Parsing ChEBI finished! Took {} seconds".format(round(time() - t1,2)))
        session.commit()
        session.close()
