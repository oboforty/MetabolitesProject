
CREATE TABLE chebi_data (
	chebi_id VARCHAR(20) NOT NULL,
	chebi_id_alt TEXT[],
	names TEXT[],
	description TEXT,
	quality INTEGER,
	charge FLOAT,
	mass FLOAT,
	monoisotopic_mass FLOAT,
	smiles TEXT,
	inchi TEXT,
	inchikey VARCHAR(27),
	formula VARCHAR(256),
	comments TEXT,
	kegg_id VARCHAR(20),
	hmdb_id VARCHAR(20),
	lipidmaps_id VARCHAR(20),
	pubchem_id VARCHAR(20),
	ref_etc TEXT,
	PRIMARY KEY (chebi_id)
)

