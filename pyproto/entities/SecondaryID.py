from pyproto.ctx import EntityBase

from sqlalchemy import Column, String


class SecondaryID(EntityBase):
    __tablename__ = 'secondary_id'

    db_tag = Column(String(12), primary_key=True)
    secondary_id = Column(String(20), primary_key=True)
    primary_id = Column(String(20))

    def __init__(self, **kwargs):
        self.db_tag = kwargs.get('db_tag')
        self.secondary_id = kwargs.get('secondary_id')
        self.primary_id = kwargs.get('primary_id')
