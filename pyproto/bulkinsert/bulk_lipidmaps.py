from time import time

from pyproto import ctx
from pyproto.entities.LipidMapsData import LipidMapsData
from pyproto.utils import parse_iter_sdf, compile_names, force_list, compile_extra_refs



def sdfdict_to_entity(v):
    # Compile attributes
    names = compile_names(
        v.get('NAME'),
        v.get('SYSTEMATIC_NAME'),
        v.get('SYNONYMS'),
        v.get('ABBREVIATION')
    )
    lipidmaps_id = v.get('LM_ID')
    lipidbank_id = v.get('LIPIDBANK_ID')

    inchi = v.get('INCHI')
    if inchi is not None:
        inchi = inchi.lstrip('InChI=')

    meta = LipidMapsData(
        lipidmaps_id = lipidmaps_id,
        names = names,
        category = v.get('CATEGORY'),
        main_class = v.get('MAIN_CLASS'),
        sub_class = v.get('SUB_CLASS'),
        lvl4_class = v.get('CLASS_LEVEL4'),
        mass = v.get('EXACT_MASS'),
        smiles = v.get('SMILES'),
        inchi = inchi,
        inchikey = v.get('INCHI_KEY'),
        formula = v.get('FORMULA'),
        kegg_id = v.get('KEGG_ID'),
        hmdb_id = v.get('HMDB_ID'),
        chebi_id = v.get('CHEBI_ID'),
        pubchem_id = v.get('PUBCHEM_CID'),
        lipidbank_id = lipidbank_id,
    )

    return meta


path_fn = '../../tmp/lipidmaps.sdf'

i = 0
session = ctx.Session()
print("Starting LipidMaps bulk import prototype")
t1 = time()

# migrate DB
if not ctx.table_exists('lipidmaps_data'):
    ctx.create_database()
else:
    print("Truncated data")
    ctx.truncate('lipidmaps_data')



for me in parse_iter_sdf(path_fn):

    meta: LipidMapsData = sdfdict_to_entity(me)
    session.add(meta)

    if i % 1000 == 0:
        print("{} entries, {} seconds".format(i, round(time() - t1, 2)))
        session.commit()
    i += 1

# save parsed entries into database
print("Parsing LipidMaps finished! Took {} seconds".format(round(time() - t1, 2)))
session.commit()
session.close()
