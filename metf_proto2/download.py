import sys

from api.discover import get_db
from api.ctx import is_db_empty, migrate, drop_all


def download(db_tag):
    """
    Downloads, parses and inserts the entire database of db_tag
    
    :param db_tag: hmdb | chebi | chemspider | kegg | lipidmaps | metlin | pubchem
    """

    # create database
    if is_db_empty():
        print("Creating database...")
        drop_all()
        migrate()

    # @TODO: port to R

    db = get_db(db_tag)

    db.download_all()


def main():
    db_tag = sys.argv[1] if len(sys.argv) > 1 else "hmdb"

    download(db_tag)
    print("DOWNLOAD finished")


if __name__ == "__main__":
    main()
