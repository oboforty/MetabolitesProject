
CREATE TABLE pubchem_data (
	pubchem_id VARCHAR(20) NOT NULL,
	names TEXT[],
	mass FLOAT,
	weight FLOAT,
	monoisotopic_mass FLOAT,
	logp FLOAT,
	smiles TEXT[],
	inchi TEXT,
	inchikey VARCHAR(27),
	formula VARCHAR(256),
	chebi_id VARCHAR(20),
	kegg_id VARCHAR(20),
	hmdb_id VARCHAR(20),
	chemspider_id VARCHAR(20),
	ref_etc TEXT,
	PRIMARY KEY (pubchem_id)
)
