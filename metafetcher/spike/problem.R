db_id = 'HMDB000001'
      SQL <- "SELECT
        pubchem_id, chebi_id, kegg_id, hmdb_id, metlin_id,
        smiles, inchi, inchikey, formula, names,
        avg_mol_weight as mass, monoisotopic_mol_weight as monoisotopic_mass
        FROM hmdb_data WHERE hmdb_id = '%s'"
      ss <- sprintf(SQL, db_id)
ss