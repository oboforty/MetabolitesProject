CREATE TABLE hmdb_data (
	hmdb_id VARCHAR(20) NOT NULL,
	hmdb_id_alt TEXT[],
	names TEXT[],
	description TEXT,
	avg_mol_weight FLOAT,
	monoisotopic_mol_weight FLOAT,
	state VARCHAR(32),
	formula TEXT,
	smiles TEXT,
	inchi TEXT,
	inchikey TEXT,
	chemspider_id VARCHAR(32),
	kegg_id VARCHAR(32),
	metlin_id VARCHAR(32),
	pubchem_id VARCHAR(32),
	chebi_id VARCHAR(20),
	PRIMARY KEY (hmdb_id)
)








