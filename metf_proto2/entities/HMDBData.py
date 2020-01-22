from api.ctx import EntityBase

from sqlalchemy import Column, Integer, String, Boolean, SmallInteger, ForeignKey, ForeignKeyConstraint, Date, DateTime, \
    TIMESTAMP, func, Float, TEXT
from eme.data_access import JSON_GEN

from entities.MixinData import MixinData


class HMDBData(EntityBase, MixinData):
    __tablename__ = 'hmdb_data'

    # Metadata
    hmdb_id = Column(String(11))
    description = Column(TEXT)

    # RefIds
    cas_id = Column(String(10))
    cas_ids = Column(TEXT)
    drugbank_id = Column(String(128))
    drugbank_metabolite_id = Column(String(128))
    chemspider_id = Column(String(128))
    kegg_id = Column(String(128))
    kegg_ids = Column(TEXT)
    metlin_id = Column(String(128))
    pubchem_compound_id = Column(String(128))
    chebi_id = Column(String(128))
    chebi_ids = Column(TEXT)

    # Fun Facts
    avg_mol_weight = Column(Float)
    MonoIsotopic_Mol_Weight = Column(Float)
    state = Column(String())
    biofluid_locations = Column(String())
    tissue_locations = Column(String())

    # Complex data
    taxonomy = Column(JSON_GEN)
    ontology = Column(JSON_GEN)
    proteins = Column(JSON_GEN)
    diseases = Column(JSON_GEN)

    # ?
    synthesis_reference = Column(TEXT)
