from time import time

import xmltodict
import xml.etree.ElementTree as ET

from api import ctx
from entities.localdb import Metabolite
from api.utils import download_file, parse_xml_recursive
from metf_proto2.api.handlers.FetcherBase import FetcherBase


class FetcherHMDB(FetcherBase):
    def __init__(self, fake=False):
        super().__init__(
            url_get='http://www.hmdb.ca/metabolites/{}.xml',
            url_all='http://www.hmdb.ca/system/downloads/current/hmdb_metabolites.zip',
            fake=fake
        )

    def parse(self, db_id, content) -> Metabolite:
        """Parses custom content"""
        if isinstance(content, dict):
            v = content
        elif isinstance(content, str):
            v = dict(xmltodict.parse(content))['metabolite']
        else:
            raise Exception("Unsupported type to parse {}".format(type(content)))

        names = [v.pop('name')]
        synonyms = v.pop('synonyms')
        if isinstance(synonyms, dict):
            names.extend(synonyms['synonym'])
        elif synonyms == '':
            pass
        else:
            print(1)


        meta = Metabolite(names=names, source='hmdb',
            hmdb_id = v.pop('accession', None),
            kegg_id = v.pop('kegg_id', None),
            chebi_id = v.pop('chebi_id', None),
            chemspider_id = v.pop('chemspider_id', None),
            pubchem_id = v.pop('pubchem_compound_id', None),
            metlin_id = v.pop('metlin_id', None),
            refs_etc={
            "drugbank": v.pop('drugbank_id', None),
            "wikipedia": v.pop('wikipedia_id', None),
            "foodb": v.pop('foodb_id', None),
            "knapsack": v.pop('knapsack_id', None),
            "biocyc": v.pop('biocyc_id', None),
            "bigg": v.pop('bigg_id', None),
            "pdb": v.pop('pdb_id', None),
            "phenol_explorer_compound": v.pop('phenol_explorer_compound_id', None),
        })


        # todo: parse data

        return meta

    def download_all(self):
        path_fn = 'tmp/hmdb_metabolites.xml'
        t1 = time()

        if not self.fake:
            download_file(self.url_all_tpl, path_fn)

        # parse XML file:
        context = ET.iterparse(path_fn, events=("start", "end"))
        context = iter(context)

        # Open DB connection
        session = ctx.Session()

        ev_1, xroot = next(context)
        i = 0

        while True:
            try:
                ev_2, xmeta = next(context)

                xdict = parse_xml_recursive(context)
                metabolite = self.parse(None, xdict)

                session.add(metabolite)

                if i % 1000 == 0:
                    print(i)
                    session.commit()

                i += 1

                # debugging
                #break
            except StopIteration:
                break

        # save parsed entries into database
        print("Parsing HMDB finished! Took {} seconds".format(round(time() - t1,2)))
        session.commit()
        session.close()
