from sqlalchemy import create_engine, inspect
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

db_engine = create_engine('sqlite:///meta.db', connect_args={'check_same_thread': False})
Session = sessionmaker(bind=db_engine)


EntityBase = declarative_base()


def migrate():
    EntityBase.metadata.create_all(db_engine)


def is_db_empty():
    table_names = set(inspect(db_engine).get_table_names())

    tables_to_have = {
        'users',
    }

    return not tables_to_have.issubset(table_names)
