from api.ctx import EntityBase

from sqlalchemy import Column, String, Float, TEXT, ARRAY, Integer
from eme.data_access import JSON_GEN


class CHEBIData(EntityBase):
    __tablename__ = 'chebi_data'

    names = Column(ARRAY(TEXT))
    iupac_names = Column(ARRAY(TEXT))
    iupac_trad_names = Column(ARRAY(TEXT))
    formulas = Column(ARRAY(TEXT))
    smiles = Column(TEXT)
    inchis = Column(ARRAY(TEXT))
    inchikeys = Column(ARRAY(TEXT))

    # Metadata - from compounds.tsv
    chebi_id = Column(String(20), primary_key=True)

    description = Column(TEXT)
    quality = Column(Integer)

    # from comments.tsv
    comments = Column(TEXT)

    # RefIds - from database_accession.tsv
    cas_ids = Column(ARRAY(String(12)))
    kegg_ids = Column(ARRAY(String(32)))
    hmdb_ids = Column(ARRAY(String(11)))
    lipidmaps_ids = Column(ARRAY(String(32)))
    pubchem_ids = Column(ARRAY(String(32)))

    # Fun facts - from chemical_data.tsv
    charge = Column(Float)
    mass = Column(Float)
    monoisotopic_mass = Column(Float)

    # Complex data
    list_of_pathways = Column(JSON_GEN)
    # ? might be omitted
    kegg_details = Column(JSON_GEN)

    def __init__(self, **kwargs):
        self.chebi_id = kwargs.get('chebi_id')

        self.names = kwargs.get('names')
        self.iupac_names = kwargs.get('iupac_names')
        self.iupac_trad_names = kwargs.get('iupac_trad_names')
        self.formulas = kwargs.get('formulas')
        self.smiles = kwargs.get('smiles')
        self.inchis = kwargs.get('inchis')
        self.inchikeys = kwargs.get('inchikeys')
        self.description = kwargs.get('description')
        self.quality = kwargs.get('quality')
        self.pubchem_ids = kwargs.get('pubchem_ids')
        self.kegg_ids = kwargs.get('kegg_ids')
        self.hmdb_ids = kwargs.get('hmdb_ids')
        self.lipidmaps_ids = kwargs.get('lipidmaps_ids')
        self.cas_ids = kwargs.get('cas_ids')
        self.charge = kwargs.get('charge')
        self.mass = kwargs.get('mass')
        self.monoisotopic_mass = kwargs.get('monoisotopic_mass')

        if isinstance(self.monoisotopic_mass, str):
            if not self.monoisotopic_mass:
                self.monoisotopic_mass = None
            else:
                self.monoisotopic_mass = float(self.monoisotopic_mass)

        if isinstance(self.mass, str):
            if not self.mass:
                self.mass = None
            else:
                self.mass = float(self.mass)

        if isinstance(self.charge, str):
            if not self.charge:
                self.charge = None
            else:
                self.charge = float(self.charge)

        if isinstance(self.quality, str):
            if not self.quality:
                self.quality = None
            else:
                self.quality = int(self.quality)
