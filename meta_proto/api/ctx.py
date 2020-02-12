from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

#db_engine = create_engine('sqlite:///meta.db', connect_args={'check_same_thread': False})
db_engine = create_engine('postgres+psycopg2://postgres:postgres@localhost/metafetcher')
Session = sessionmaker(bind=db_engine)


EntityBase = declarative_base()


def migrate():
    EntityBase.metadata.create_all(db_engine)


def drop_all():
    EntityBase.metadata.drop_all(db_engine)


def is_db_empty():
    table_names = set(inspect(db_engine).get_table_names())

    tables_to_have = {
        'users',
    }

    return not tables_to_have.issubset(table_names)

_sess = None
def get_session():
    global _sess
    if _sess is None:
        _sess = Session()

    return _sess

def get_engine():
    return db_engine


def query(sql, **par):
    session = get_session()

    r = session.execute(text(sql), params=par)

    return r
