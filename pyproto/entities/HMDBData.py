from pyproto.ctx import EntityBase

from sqlalchemy import Column, String, Float, TEXT, ARRAY
from eme.data_access import JSON_GEN


class HMDBData(EntityBase):
    __tablename__ = 'hmdb_data'

    # Metadata
    hmdb_id = Column(String(20), primary_key=True)
    hmdb_id_alt = Column(ARRAY(String(20)))

    names = Column(ARRAY(TEXT))

    description = Column(TEXT)

    # Fun Facts
    avg_mol_weight = Column(Float)
    monoisotopic_mol_weight = Column(Float)
    state = Column(String(32))

    # structure data
    formula = Column(TEXT)
    smiles = Column(TEXT)
    inchi = Column(TEXT)
    inchikey = Column(TEXT)

    # RefIds
    chemspider_id = Column(String(32))
    kegg_id = Column(String(32))
    metlin_id = Column(String(32))
    pubchem_id = Column(String(32))
    chebi_id = Column(String(20))

    # cas_id = Column(String(20))
    # drugbank_id = Column(String(32))
    # drugbank_metabolite_id = Column(String(32))

    # biofluid_locations = Column(ARRAY(String(64)))
    # tissue_locations = Column(ARRAY(String(64)))
    #
    # # Complex data
    # taxonomy = Column(JSON_GEN)
    # ontology = Column(JSON_GEN)
    # proteins = Column(JSON_GEN)
    # diseases = Column(JSON_GEN)

    # synthesis_reference = Column(TEXT)

    def __init__(self, **kwargs):
        self.hmdb_id = kwargs.get('hmdb_id')
        self.hmdb_id_alt = kwargs.get('hmdb_id_alt')
        self.names = kwargs.get('names')
        self.description = kwargs.get('description')
        self.avg_mol_weight = kwargs.get('avg_mol_weight')
        self.monoisotopic_mol_weight = kwargs.get('monoisotopic_mol_weight')
        self.state = kwargs.get('state')
        self.formula = kwargs.get('formula')
        self.smiles = kwargs.get('smiles')
        self.inchi = kwargs.get('inchi')
        self.inchikey = kwargs.get('inchikey')
        self.chemspider_id = kwargs.get('chemspider_id')
        self.kegg_id = kwargs.get('kegg_id')
        self.metlin_id = kwargs.get('metlin_id')
        self.pubchem_id = kwargs.get('pubchem_id')
        self.chebi_id = kwargs.get('chebi_id')

        if isinstance(self.avg_mol_weight, str):
            if not self.avg_mol_weight:
                self.avg_mol_weight = None
            else:
                self.avg_mol_weight = str(self.avg_mol_weight)

        if isinstance(self.monoisotopic_mol_weight, str):
            if not self.monoisotopic_mol_weight:
                self.monoisotopic_mol_weight = None
            else:
                self.monoisotopic_mol_weight = str(self.monoisotopic_mol_weight)
