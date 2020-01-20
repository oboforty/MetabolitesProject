from sqlalchemy.sql.ddl import CreateTable

from api.localdb import Metabolite


def get_sql():
    print(CreateTable(Metabolite.__table__))


if __name__ == "__main__":
    get_sql()
