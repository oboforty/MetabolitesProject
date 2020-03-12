from pyproto.ctx import EntityBase

from sqlalchemy import Column, String, Float, TEXT, ARRAY, Integer, ForeignKey
from eme.data_access import JSON_GEN


class CHEBIData(EntityBase):
    __tablename__ = 'chebi_data'

    # Metadata - from compounds.tsv
    chebi_id = Column(String(20), primary_key=True)
    chebi_id_alt = Column(ARRAY(String(20)))

    #chebi_name = Column(TEXT)
    names = Column(ARRAY(TEXT))

    description = Column(TEXT)
    quality = Column(Integer)

    # Fun facts - from chemical_data.tsv
    charge = Column(Float)
    mass = Column(Float)
    monoisotopic_mass = Column(Float)

    # structure info -
    smiles = Column(TEXT)
    inchi = Column(TEXT)
    inchikey = Column(String(27))
    formula = Column(String(256))

    # from comments.tsv
    comments = Column(TEXT)

    # RefIds - from database_accession.tsv
    #cas_id = Column(String(20))
    kegg_id = Column(String(20), ForeignKey('kegg_data.kegg_id'))
    hmdb_id = Column(String(20), ForeignKey('hmdb_data.hmdb_id'))
    lipidmaps_id = Column(String(20), ForeignKey('lipidmaps_data.lipidmaps_id'))
    pubchem_id = Column(String(20), ForeignKey('pubchem_data.pubchem_id'))

    ref_etc = Column(JSON_GEN())

    def __init__(self, **kwargs):
        self.chebi_id = kwargs.get('chebi_id')
        self.chebi_id_alt = kwargs.get('chebi_id_alt')
        self.chebi_name = kwargs.get('chebi_name')
        self.names = kwargs.get('names')
        self.description = kwargs.get('description')
        self.quality = kwargs.get('quality')
        self.charge = kwargs.get('charge')
        self.mass = kwargs.get('mass')
        self.monoisotopic_mass = kwargs.get('monoisotopic_mass')
        self.smiles = kwargs.get('smiles')
        self.inchi = kwargs.get('inchi')
        self.inchikey = kwargs.get('inchikey')
        self.formula = kwargs.get('formula')
        self.comments = kwargs.get('comments')
        #self.cas_id = kwargs.get('cas_id')
        self.kegg_id = kwargs.get('kegg_id')
        self.hmdb_id = kwargs.get('hmdb_id')
        self.lipidmaps_id = kwargs.get('lipidmaps_id')
        self.pubchem_id = kwargs.get('pubchem_id')
        self.ref_etc = kwargs.get('ref_etc')

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
