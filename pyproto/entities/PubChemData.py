from pyproto.ctx import EntityBase

from sqlalchemy import Column, String, Float, TEXT, ARRAY, Integer
from eme.data_access import JSON_GEN


class PubChemData(EntityBase):
    __tablename__ = 'pubchem_data'

    pubchem_id = Column(String(20), primary_key=True)

    names = Column(ARRAY(TEXT))

    mass = Column(Float)
    weight = Column(Float)
    monoisotopic_mass = Column(Float)
    logp = Column(Float)

    # structure info -
    smiles = Column(ARRAY(TEXT))
    inchi = Column(TEXT)
    inchikey = Column(String(27))
    formula = Column(String(256))

    chebi_id = Column(String(20))
    kegg_id = Column(String(20))
    hmdb_id = Column(String(20))
    chemspider_id = Column(String(20))


    ref_etc = Column(JSON_GEN())

    def __init__(self, **kwargs):
        pass