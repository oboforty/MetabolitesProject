from api.ctx import EntityBase

from sqlalchemy import Column, String, Float, TEXT, ARRAY
from eme.data_access import JSON_GEN


class HMDBData(EntityBase):
    __tablename__ = 'hmdb_data'

    # Metadata
    hmdb_id = Column(String(11), primary_key=True)

    description = Column(TEXT)

    names = Column(ARRAY(TEXT))
    iupac_name = Column(TEXT)
    iupac_trad_name = Column(TEXT)
    formula = Column(TEXT)
    smiles = Column(TEXT)
    inchi = Column(TEXT)
    inchikey = Column(TEXT)

    # RefIds
    cas_id = Column(String(12))
    drugbank_id = Column(String(32))
    drugbank_metabolite_id = Column(String(32))
    chemspider_id = Column(String(32))
    kegg_id = Column(String(32))
    metlin_id = Column(String(32))
    pubchem_id = Column(String(32))
    chebi_id = Column(String(20))

    # kegg_ids = Column(TEXT)
    # cas_ids = Column(TEXT)
    # chebi_ids = Column(TEXT)

    # Fun Facts
    avg_mol_weight = Column(Float)
    monoisotopic_mol_weight = Column(Float)
    state = Column(String(32))

    biofluid_locations = Column(ARRAY(String(64)))
    tissue_locations = Column(ARRAY(String(64)))

    # Complex data
    taxonomy = Column(JSON_GEN)
    ontology = Column(JSON_GEN)
    proteins = Column(JSON_GEN)
    diseases = Column(JSON_GEN)

    # ?
    synthesis_reference = Column(TEXT)

    def __init__(self, **kwargs):
        self.hmdb_id = kwargs.get('hmdb_id')

        self.names = kwargs.get('names')
        self.iupac_name = kwargs.get('iupac_name')
        self.iupac_trad_name = kwargs.get('iupac_trad_name')
        self.formula = kwargs.get('formula')
        self.smiles = kwargs.get('smiles')
        self.inchi = kwargs.get('inchi')
        self.inchikey = kwargs.get('inchikey')


        self.description = kwargs.get('description')
        self.cas_id = kwargs.get('cas_id')
        self.drugbank_id = kwargs.get('drugbank_id')
        self.drugbank_metabolite_id = kwargs.get('drugbank_metabolite_id')
        self.chemspider_id = kwargs.get('chemspider_id')
        self.kegg_id = kwargs.get('kegg_id')
        self.metlin_id = kwargs.get('metlin_id')
        self.pubchem_id = kwargs.get('pubchem_id')
        self.chebi_id = kwargs.get('chebi_id')
        self.avg_mol_weight = kwargs.get('avg_mol_weight')
        self.monoisotopic_mol_weight = kwargs.get('monoisotopic_mol_weight')
        self.state = kwargs.get('state')
        self.biofluid_locations = kwargs.get('biofluid_locations')
        self.tissue_locations = kwargs.get('tissue_locations')
        self.taxonomy = kwargs.get('taxonomy')
        self.ontology = kwargs.get('ontology')
        self.proteins = kwargs.get('proteins')
        self.diseases = kwargs.get('diseases')
        self.synthesis_reference = kwargs.get('synthesis_reference')

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
