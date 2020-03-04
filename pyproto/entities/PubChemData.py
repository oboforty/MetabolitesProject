from pyproto.ctx import EntityBase

from sqlalchemy import Column, String, Float, TEXT, ARRAY, Integer
from eme.data_access import JSON_GEN


class PubChemData(EntityBase):
    __tablename__ = 'pubchem_data'

    pubchem_id = Column(String(20), primary_key=True)
    #
    # names = Column(ARRAY(TEXT))
    #
    # description = Column(TEXT)
    # quality = Column(Integer)
    #
    # charge = Column(Float)
    # mass = Column(Float)
    # monoisotopic_mass = Column(Float)
    #
    # # structure info -
    smiles = Column(TEXT)
    inchi = Column(TEXT)
    inchikey = Column(String(27))
    formula = Column(String(256))
    #
    # # from comments.tsv
    # comments = Column(TEXT)
    #
    # # RefIds - from database_accession.tsv
    # chebi_id = Column(String(20))
    # kegg_id = Column(String(20))
    # hmdb_id = Column(String(20))
    # lipidmaps_id = Column(String(20))
    # #cas_id = Column(String(20))

    ref_etc = Column(JSON_GEN())

    def __init__(self, **kwargs):
        pass