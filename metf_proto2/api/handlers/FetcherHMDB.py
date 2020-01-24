from time import time

import xmltodict
import xml.etree.ElementTree as ET

from api import ctx
from api.utils import download_file, parse_xml_recursive
from api.entities.HMDBData import HMDBData
from metf_proto2.api.handlers.FetcherBase import FetcherBase


class FetcherHMDB(FetcherBase):
    def __init__(self, fake=False):
        super().__init__(
            url_get='http://www.hmdb.ca/metabolites/{}.xml',
            url_all='http://www.hmdb.ca/system/downloads/current/hmdb_metabolites.zip',
            fake=fake
        )

    def parse(self, db_id, content) -> HMDBData:
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

        # todo: secondary accessions -> to lookup table?
        # todo: cas_registry_number, pathways
        # todo: tissue_locations

        meta = HMDBData(hmdb_id = v.get('accession'),
            description = v.get('description'),

            names = names,
            iupac_name = v.get('iupac_name'),
            iupac_trad_name = v.get('traditional_iupac'),
            formula = v.get('chemical_formula'),
            smiles = v.get('smiles'),
            inchi = v.get('inchi'),
            inchikey = v.get('inchikey'),

            cas_id = v.get('cas_id'),
            drugbank_id = v.get('drugbank_id'),
            drugbank_metabolite_id = v.get('drugbank_metabolite_id'),
            chemspider_id = v.get('chemspider_id'),
            kegg_id = v.get('kegg_id'),
            metlin_id = v.get('metlin_id'),
            pubchem_id = v.get('pubchem_id'),
            chebi_id = v.get('chebi_id'),
            avg_mol_weight = v.get('average_molecular_weight'),
            monoisotopic_mol_weight = v.get('monisotopic_molecular_weight'),
            state = v.get('state'),
            biofluid_locations = [f['biofluid'] for f in v.get('biofluid_locations', [])],
            #tissue_locations = [f['tissue'] for f in v.get('tissue_locations', [])],
            taxonomy = v.get('taxonomy'),
            ontology = v.get('ontology'),
            proteins = v.get('protein_associations'),
            diseases = v.get('diseases'),
            synthesis_reference = v.get('synthesis_reference'),
        )

        return meta

    def download_all(self):
        path_fn = '../tmp/hmdb_metabolites.xml'
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

                i += 1
                if i % 5000 == 0:
                    print("{} entries, {} seconds".format(i, round(time()-t1,2)))
                    session.commit()

                # debugging
                #break
            except StopIteration:
                break

        # save parsed entries into database
        print("Parsing HMDB finished! Took {} seconds".format(round(time() - t1,2)))
        session.commit()
        session.close()
