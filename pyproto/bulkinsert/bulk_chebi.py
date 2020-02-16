from time import time

from pyproto import ctx
from pyproto.entities.ChEBIData import CHEBIData
from pyproto.utils import parse_iter_sdf, compile_names, force_list, compile_extra_refs



def sdfdict_to_entity(v):
    # Compile attributes
    names = compile_names(v.get('ChEBI Name'), v.get('IUPAC Names'), v.get('Synonyms'))
    chebi_id = v.get('ChEBI ID').lstrip('CHEBI:')
    chebi_id_alt = force_list(v.get('Secondary ChEBI ID'), lambda e: e.lstrip('CHEBI:'))

    refs_multiple = {}

    # preparse pubchem
    if 'PubChem Database Links' not in v and 'Pubchem Database Links' in v:
        v['PubChem Database Links'] = v['Pubchem Database Links']
    if 'PubChem Database Links' in v:
        v['PubChem Database Links'] = list(filter(lambda x: x.startswith('CID: '), v['PubChem Database Links']))

    # todo: comments?
    # todo: pubchem SID filter out?

    meta = CHEBIData(
        chebi_id = chebi_id,
        chebi_id_alt = chebi_id_alt,
        names = names,

        description = v.get('definition'),
        quality = int(v.get('Star', 0)),
        charge = v.get('Charge'),
        mass = v.get('Mass'),
        monoisotopic_mass = v.get('Monoisotopic Mass'),

        formula = compile_extra_refs(refs_multiple, v.get('Formulae'), 'formula'),
        smiles = compile_extra_refs(refs_multiple, v.get('SMILES'), 'smiles'),
        inchi = compile_extra_refs(refs_multiple, v.get('InChI'), 'inchi', parse=lambda e: e.lstrip('InChI=')),
        inchikey = compile_extra_refs(refs_multiple, v.get('InChIKey'), 'inchikey'),

        hmdb_id = compile_extra_refs(refs_multiple, v.get('HMDB Database Links'), 'hmdb_id'),
        lipidmaps_id = compile_extra_refs(refs_multiple, v.get('LIPID MAPS instance Database Links'), 'lipidmaps_id'),
        pubchem_id = compile_extra_refs(refs_multiple, v.get('PubChem Database Links'), 'pubchem_id'),
        kegg_id = compile_extra_refs(refs_multiple, v.get('KEGG COMPOUND Database Links'), 'kegg_id'),
        # cas_id = compile_extra_refs(refs_multiple, v, 'CAS Registry Numbers'),
    )

    # in some extra cases there's multiple cardinality
    meta.ref_etc = refs_multiple

    return meta


path_fn = '../../tmp/ChEBI_complete.sdf'

i = 0
session = ctx.Session()
print("Starting ChEBI bulk import prototype")
t1 = time()

# migrate DB
if not ctx.table_exists('chebi_data'):
    ctx.create_database()
else:
    print("Truncated data")
    ctx.truncate('chebi_data')



for me in parse_iter_sdf(path_fn):

    meta: CHEBIData = sdfdict_to_entity(me)

    session.add(meta)

    if i % 1000 == 0:
        print("{} entries, {} seconds".format(i, round(time() - t1, 2)))
        session.commit()
    i += 1

# save parsed entries into database
print("Parsing ChEBI finished! Took {} seconds".format(round(time() - t1, 2)))
session.commit()
session.close()
