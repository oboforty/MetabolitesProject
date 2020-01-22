from sqlalchemy import Column, TEXT


class MixinData(object):
    """A common interface for all metabolome DB tables."""

    names = Column(TEXT)
    iupac_names = Column(TEXT)
    iupac_trad_names = Column(TEXT)

    formula = Column(TEXT)
    smiles = Column(TEXT)
    inchi = Column(TEXT)
    inchikey = Column(TEXT)
