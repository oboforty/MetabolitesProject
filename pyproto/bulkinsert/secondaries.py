from time import time

from pyproto import ctx
from pyproto.entities.ChEBIData import CHEBIData
from pyproto.utils import parse_iter_sdf, compile_names, force_list, compile_extra_refs


if not ctx.table_exists('secondary_id'):
    ctx.create_database()
else:
    print("Truncated data")
    ctx.truncate('secondary_id')
sess = ctx.get_session()

sess.execute("""
INSERT INTO secondary_id
  SELECT 'chebi_id' as "db_tag", unnest(chebi_id_alt) as "secondary_id", chebi_id as "primary_id"
  FROM chebi_data
""")

sess.execute("""
INSERT INTO secondary_id
  SELECT 'hmdb_id' as "db_tag", unnest(hmdb_id_alt) as "secondary_id", hmdb_id as "primary_id"
  FROM hmdb_data
""")
