import json
from collections import defaultdict

from pyproto.utils import parse_iter_sdf, rlen

path_fn = '../../tmp/chebi_tsv/database_accession.tsv'

foreign = set()

with open(path_fn, 'r', encoding='utf8') as fh:
    buffer = {}
    state = None

    for line in fh:
        ID,COMPOUND_ID,SOURCE,TYPE,ACCESSION_NUMBER = line.rstrip('\n').split('\t')

        if SOURCE == 'KEGG' and TYPE == 'COMPOUND':
            foreign.add(('kegg',ACCESSION_NUMBER))
        elif SOURCE == 'HMDB':
            foreign.add(('hmdb',ACCESSION_NUMBER))
        elif SOURCE == 'LIPID MAPS':
            foreign.add(('lipidmaps',ACCESSION_NUMBER))
        # elif SOURCE == 'PubChem':
        #     foreign.add(('pubchem',ACCESSION_NUMBER))
        #elif SOURCE == 'ChEBI':
        #    foreign.add(('chebi',ACCESSION_NUMBER))
        elif SOURCE == 'Chemspider':
            foreign.add(('chemspider',ACCESSION_NUMBER))

print(len(foreign))
