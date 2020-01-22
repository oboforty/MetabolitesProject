from api.ctx import EntityBase

from sqlalchemy import Column, Integer, String, Boolean, SmallInteger, ForeignKey, ForeignKeyConstraint, Date, DateTime, \
    TIMESTAMP, func, Float, TEXT
from eme.data_access import JSON_GEN

from entities.MixinData import MixinData


class CHEBIData(EntityBase, MixinData):
    __tablename__ = 'chebi_data'

    # Metadata - from compounds.tsv
    chebi_id = Column(String(11))
    name = Column(TEXT)
    descrption = Column(TEXT)
    quality = Column(TEXT)

    # from names.tsv
    names = Column(TEXT)
    # from comments.tsv
    comments = Column(TEXT)

    # RefIds - from database_accession.tsv
    cas_id = Column(TEXT)
    kegg_id = Column(TEXT)
    hmdb_id = Column(TEXT)
    lipidmaps_id = Column(TEXT)
    pubchem_id = Column(TEXT)

    # Fun facts - from chemical_data.tsv
    charge = Column(TEXT)
    mass = Column(TEXT)
    monoisotopic_mass = Column(TEXT)

    # Complex data
    list_of_pathways = Column(JSON_GEN)
    # ? might be omitted
    kegg_details = Column(JSON_GEN)
