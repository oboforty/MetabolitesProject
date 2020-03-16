CREATE TABLE kegg_data (
	kegg_id VARCHAR(20) NOT NULL,
	names TEXT[],
	exact_mass FLOAT,
	mol_weight FLOAT,
	comments TEXT,
	formula VARCHAR(256),
	chebi_id VARCHAR(20),
	lipidmaps_id VARCHAR(20),
	pubchem_id VARCHAR(20),
	ref_etc TEXT,
	PRIMARY KEY (kegg_id)
)

