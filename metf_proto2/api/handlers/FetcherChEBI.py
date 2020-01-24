from time import time

import xmltodict

from .. import ctx
from ..entities.ChEBIData import CHEBIData
from ..utils import download_file_ftp, parse_iter_sdf
from .FetcherBase import FetcherBase


def los(v, f=None):
    if isinstance(v, list):
        if f is not None:
            return [f(e) for e in v]
        return v
    elif v is None:
        return None
    else:
        if f is not None:
            return f(v)
        return [v]


class FetcherChEBI(FetcherBase):
    def __init__(self, fake=False):
        super().__init__(
            url_get='https://www.ebi.ac.uk/webservices/chebi/2.0/test/getCompleteEntity?chebiId={}',
            url_all='http://www.hmdb.ca/system/downloads/current/hmdb_metabolites',
            fake=fake
        )

    def parse(self, db_id, content):
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

    def _parse_bulk_sdfdict(self, v):

        # Discover names:
        names = [v.pop('ChEBI Name')]
        syn = v.pop('Synonyms', None)
        if syn:
            if isinstance(syn, str):
                names.append(syn)
            else:
                names.extend(syn)


        # todo: comments
        # todo: pubchem SID filter out?
        # todo: Secondary ChEBI ID
        # todo: iupac_trad_name

        #f = [x.rstrip('CID: ') for x in v.get('PubChem Database Links', []) if x.startswith('CID:')]

        meta = CHEBIData(chebi_id = v.get('ChEBI ID').lstrip('CHEBI:'),
            names = names,
            iupac_names = los(v.get('IUPAC Names')),
            iupac_trad_names = None,
            formulas =  los(v.get('Formulae')),
            smiles = v.get('SMILES'),
            inchis = los(v.get('InChI'), lambda e: e.lstrip('InChI=')),
            inchikeys = los(v.get('InChIKey')),

            description = v.get('definition'),
            quality = int(v.get('Star')),
            # comments = v.get('comments'),
            pubchem_ids = los(v.get('PubChem Database Links', v.get('Pubchem Database Links'))),
            kegg_ids = los(v.get('KEGG COMPOUND Database Links')),
            hmdb_ids = los(v.get('HMDB Database Links')),
            lipidmaps_ids = los(v.get('LIPID MAPS instance Database Links')),
            cas_ids = los(v.get('CAS Registry Numbers')),
            charge = v.get('Charge'),
            mass = v.get('Mass'),
            monoisotopic_mass = v.get('Monoisotopic Mass'),
            # list_of_pathways = v.get('list_of_pathways'),
            # kegg_details = v.get('kegg_details'),
        )

        # meta = Metabolite(names=names, source='chebi', refs_etc={})
        #
        # # automatically discover refids:
        # meta.chebi_id = sdfdict.pop('ChEBI ID')
        # xref_tpl = ' Database Links'
        # for _key in list(sdfdict.keys()):
        #     if _key is not None and _key.endswith(xref_tpl):
        #         db_tag = _key.rstrip(xref_tpl)
        #         db_id = sdfdict.pop(_key)
        #
        #         if 'kegg' in db_tag:
        #             setattr(meta, db_tag, db_id)
        #         else:
        #             meta.refs_etc[db_tag] = db_id
        #
        # # todo: add SMILES, InChI, formulae
        #
        # # todo: add additional data

        return meta

    def download_all(self):
        path_fn = '../tmp/ChEBI_complete.sdf'
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
