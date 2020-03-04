from time import time
import xml.etree.ElementTree as ET
import xmltodict

from pyproto import ctx
from pyproto.entities.HMDBData import HMDBData
from pyproto.utils import compile_names, force_list, compile_extra_refs, parse_xml_recursive

def nono(v):
    if not v: return None
    return v


def xml_to_entity(v):
    # Compile attributes
    names = compile_names(v.get('name'), v.get('iupac_name'), v.get('traditional_iupac'), force_list(v['synonyms']['synonym']) if v['synonyms'] else [])
    hmdb_id = v.get('accession')
    hmdb_id_alt = force_list(v['secondary_accessions']['accession']) if v.get('secondary_accessions') else None


    inchi = nono(v.get('inchi'))
    if inchi is not None:
        inchi = inchi.lstrip('InChI=')

    #refs_multiple = {}

    meta = HMDBData(
        hmdb_id = hmdb_id,
        names = names,

        description = v.get('description'),
        avg_mol_weight=v.get('average_molecular_weight'),
        monoisotopic_mol_weight=v.get('monisotopic_molecular_weight'),
        state=v.get('state'),

        formula = nono(v.get('chemical_formula')),
        smiles = nono(v.get('smiles')),
        inchi = inchi,
        inchikey = nono(v.get('inchikey')),

        chebi_id=nono(v.get('chebi_id')),
        kegg_id=nono(v.get('kegg_id')),
        pubchem_id=nono(v.get('pubchem_compound_id')),
        metlin_id=nono(v.get('metlin_id')),
        chemspider_id=nono(v.get('chemspider_id')),
        # cas_id=v.get('cas_id'),
        # drugbank_id=v.get('drugbank_id'),
        # drugbank_metabolite_id=v.get('drugbank_metabolite_id'),
    )

    # remove redundant secondary IDs
    if hmdb_id_alt:
        meta.hmdb_id_alt = list(filter(lambda x: not (len(x) == 9 and ('HMDB00'+x[4:] in hmdb_id_alt or 'HMDB00'+x[4:] == hmdb_id)), hmdb_id_alt))

    # in some extra cases there's multiple cardinality
    #meta.ref_etc = refs_multiple

    return meta


i = 0
session = ctx.Session()
print("Starting HMDB bulk import prototype")

# migrate DB
if not ctx.table_exists('hmdb_data'):
    ctx.create_database()
else:
    print("Truncated data")
    ctx.truncate('hmdb_data')

t1 = time()
path_fn = '../../tmp/hmdb_metabolites.xml'

# parse XML file:
context = ET.iterparse(path_fn, events=("start", "end"))
context = iter(context)

ev_1, xroot = next(context)
i = 0

while True:
    try:
        ev_2, xmeta = next(context)

        xdict = parse_xml_recursive(context)
        if isinstance(xdict, str) and xdict =='':
            # end of xml
            continue

        metabolite = xml_to_entity(xdict)

        session.add(metabolite)

        i += 1
        if i % 5000 == 0:
            print("{} entries, {} seconds".format(i, round(time() - t1, 2)))
            session.commit()

        # debugging
        # break
    except StopIteration:
        break

# save parsed entries into database
print("Parsing HMDB finished! Took {} seconds".format(round(time() - t1, 2)))
session.commit()
session.close()
