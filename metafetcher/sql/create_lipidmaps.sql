
CREATE TABLE lipidmaps_data (
	lipidmaps_id VARCHAR(20) NOT NULL,
	names TEXT[],
	category VARCHAR(32),
	main_class VARCHAR(64),
	sub_class VARCHAR(128),
	lvl4_class VARCHAR(128),
	mass FLOAT,
	smiles TEXT,
	inchi TEXT,
	inchikey VARCHAR(27),
	formula VARCHAR(256),
	kegg_id VARCHAR(20),
	hmdb_id VARCHAR(20),
	chebi_id VARCHAR(20),
	pubchem_id VARCHAR(20),
	lipidbank_id VARCHAR(20),
	PRIMARY KEY (lipidmaps_id)
)

