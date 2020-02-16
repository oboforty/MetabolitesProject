from sqlalchemy.sql.ddl import CreateTable

from pyproto.entities.HMDBData import HMDBData
from pyproto.entities import CHEBIData
from pyproto.entities.metabolite import Metabolite


def get_sql():
    print(CreateTable(Metabolite.__table__))
    print(CreateTable(HMDBData.__table__))
    print(CreateTable(CHEBIData.__table__))


if __name__ == "__main__":
    get_sql()
