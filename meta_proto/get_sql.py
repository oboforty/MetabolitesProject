from sqlalchemy.sql.ddl import CreateTable

from api.entities.HMDBData import HMDBData
from api.entities.ChEBIData import CHEBIData
from api.entities.metabolite import Metabolite


def get_sql():
    print(CreateTable(Metabolite.__table__))
    print(CreateTable(HMDBData.__table__))
    print(CreateTable(CHEBIData.__table__))


if __name__ == "__main__":
    get_sql()
