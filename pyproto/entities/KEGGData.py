from pyproto.ctx import EntityBase

from sqlalchemy import Column, String, Float, TEXT, ARRAY, Integer, ForeignKey
from eme.data_access import JSON_GEN


class KeggData(EntityBase):
    __tablename__ = 'kegg_data'

    kegg_id = Column(String(20), primary_key=True)

    names = Column(ARRAY(TEXT))

    exact_mass = Column(Float)
    mol_weight = Column(Float)

    comments = Column(TEXT)

    # structure info -
    formula = Column(String(256))

    # RefIds - from database_accession.tsv
    #cas_id = Column(String(20))
    chebi_id = Column(String(20), ForeignKey('chebi_data.chebi_id'))
    lipidmaps_id = Column(String(20), ForeignKey('lipidmaps_data.lipidmaps_id'))
    pubchem_id = Column(String(20), ForeignKey('pubchem_data.pubchem_id'))

    ref_etc = Column(JSON_GEN())

    def __init__(self, **kwargs):
        self.kegg_id = kwargs.get('kegg_id')
        self.names = kwargs.get('names')
        self.exact_mass = kwargs.get('exact_mass')
        self.mol_weight = kwargs.get('mol_weight')
        self.comments = kwargs.get('comments')
        self.formula = kwargs.get('formula')
        self.cas_id = kwargs.get('cas_id')
        self.kegg_id = kwargs.get('kegg_id')
        self.chebi_id = kwargs.get('chebi_id')
        self.lipidmaps_id = kwargs.get('lipidmaps_id')
        self.pubchem_id = kwargs.get('pubchem_id')
        self.ref_etc = kwargs.get('ref_etc')

        if isinstance(self.mol_weight, str):
            if not self.mol_weight:
                self.mol_weight = None
            else:
                self.mol_weight = float(self.mol_weight)

        if isinstance(self.exact_mass, str):
            if not self.exact_mass:
                self.exact_mass = None
            else:
                self.exact_mass = float(self.exact_mass)

