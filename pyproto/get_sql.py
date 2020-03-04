from sqlalchemy.sql.ddl import CreateTable

from pyproto.entities.ChEBIData import CHEBIData
from pyproto.entities.HMDBData import HMDBData
from pyproto.entities.KEGGData import KeggData
from pyproto.entities.LipidMapsData import LipidMapsData
from pyproto.entities.SecondaryID import SecondaryID


def f(x):
    return set(str(c).split('.')[1] for c in x.__table__.columns)


def get_sql():
    print(CreateTable(HMDBData.__table__))
    print(CreateTable(CHEBIData.__table__))
    print(CreateTable(LipidMapsData.__table__))
    print(CreateTable(KeggData.__table__))
    print(CreateTable(SecondaryID.__table__))

    # lm = f(LipidMapsData)
    # hm = f(HMDBData)
    # ch = f(CHEBIData)
    #
    #
    # common = (hm | ch) & (lm | hm) & (lm | ch) | {'monoisotopic_mass', 'mass'}
    #
    # print("Common:", common)
    # print("+HMDB:", hm - common)
    # print("+Chebi:", ch - common)
    # print("+Lipidmaps:", lm - common)


if __name__ == "__main__":
    get_sql()
