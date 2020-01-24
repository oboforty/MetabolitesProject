import string
import random

from sqlalchemy import Column, Integer, String, Boolean, SmallInteger, ForeignKey, ForeignKeyConstraint, Date, DateTime, \
    TIMESTAMP, func, Float
from eme.data_access import GUID, JSON_GEN

from api.ctx import EntityBase


def newmid():
    return ''.join(random.choice(string.ascii_lowercase) for i in range(8))



class Metabolite(EntityBase):
    __tablename__ = 'metabolites'
    __table_args__ = {'sqlite_autoincrement': True}

    mid = Column(Integer, primary_key=True)

    downloaded_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.current_timestamp())
    names = Column(JSON_GEN())
    # Describes where this metabolite is originated from
    source = Column(String(20))
    source_id = Column(String(128))

    hmdb_id = Column(String(11))
    chebi_id = Column(String(128))
    kegg_id = Column(String(128))
    pubchem_id = Column(String(128))
    chemspider_id = Column(String(128))
    lipidmaps_id = Column(String(128))
    metlin_id = Column(String(128))

    refs_etc = Column(JSON_GEN())
    data = Column(JSON_GEN())

    def __init__(self, **kwargs):
        self.mid = kwargs.get('mid')
        self.names = kwargs.get('names', [])
        self.downloaded_at = kwargs.get('downloaded_at')
        self.source = kwargs.get('source')
        #self.source_id = kwargs.get('source_id')

        # Xrefs
        self.hmdb_id = kwargs.get('hmdb_id')
        self.chebi_id = kwargs.get('chebi_id')
        self.kegg_id = kwargs.get('kegg_id')
        self.pubchem_id = kwargs.get('pubchem_id')
        self.chemspider_id = kwargs.get('chemspider_id')
        self.lipidmaps_id = kwargs.get('lipidmaps_id')
        self.metlin_id = kwargs.get('metlin_id')

        # Other, unused data
        self.refs_etc = kwargs.get('refs_etc')
        self.data = kwargs.get('data')

    @property
    def refs(self):
        return {
            "hmdb": self.hmdb_id,
            "chebi": self.chebi_id,
            "kegg": self.kegg_id,
            "pubchem": self.pubchem_id,
            "chemspider": self.chemspider_id,
            "lipidmaps": self.lipidmaps_id,
            "metlin": self.metlin_id,
        }

    @property
    def view(self):
        return {
            "mid": self.mid,
            "names": self.names,
            "downloaded_at": self.downloaded_at,
            "hmdb_id": self.hmdb_id,
            "chebi_id": self.chebi_id,
            "kegg_id": self.kegg_id,
            "pubchem_id": self.pubchem_id,
            "chemspider_id": self.chemspider_id,
            "lipidmaps_id": self.lipidmaps_id,
            "metlin_id": self.metlin_id,
            "refs_etc": self.refs_etc,
            "data": self.data,
        }
