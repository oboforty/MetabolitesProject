from api.ctx import EntityBase

from sqlalchemy import Column, String, Float, TEXT, ARRAY, Integer, Sequence
from eme.data_access import JSON_GEN


class Metabolite(EntityBase):
    __tablename__ = 'metabolite_references'

    # MID
    mid_v1 = Column(Integer, primary_key=True)
    # mid_v2 = finding a common unqiue attribute
    # mid_v3 or mid3 = our own custom unique attribute

    # Names & formulas
    names = Column(ARRAY(TEXT))
    formulas = Column(ARRAY(TEXT))
    smiles = Column(ARRAY(TEXT))
    inchis = Column(ARRAY(TEXT))
    inchikeys = Column(ARRAY(TEXT))

    # RefIds
    chebi_ids = Column(ARRAY(String(20)))
    cas_ids = Column(ARRAY(String(12)))
    kegg_ids = Column(ARRAY(String(32)))
    hmdb_ids = Column(ARRAY(String(11)))
    lipidmaps_ids = Column(ARRAY(String(32)))
    pubchem_ids = Column(ARRAY(String(32)))

    def __init__(self, **kwargs):
        # todo: implement better algorithms
        #self.mid_v2 = kwargs.get('mid')

        self.names = kwargs.get('names')
        self.iupac_names = kwargs.get('iupac_names')
        self.iupac_trad_names = kwargs.get('iupac_trad_names')
        self.formulas = kwargs.get('formulas')
        self.smiles = kwargs.get('smiles')
        self.inchis = kwargs.get('inchis')
        self.inchikeys = kwargs.get('inchikeys')
        self.chebi_ids = kwargs.get('chebi_ids')
        self.cas_ids = kwargs.get('cas_ids')
        self.kegg_ids = kwargs.get('kegg_ids')
        self.hmdb_ids = kwargs.get('hmdb_ids')
        self.lipidmaps_ids = kwargs.get('lipidmaps_ids')
        self.pubchem_ids = kwargs.get('pubchem_ids')
