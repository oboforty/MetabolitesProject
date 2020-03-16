-- Chebi
ALTER TABLE chebi_data ADD CONSTRAINT fk_chebi_kegg FOREIGN KEY(kegg_id) REFERENCES kegg_data (kegg_id);
ALTER TABLE chebi_data ADD CONSTRAINT fk_chebi_hmdb FOREIGN KEY(hmdb_id) REFERENCES hmdb_data (hmdb_id);
ALTER TABLE chebi_data ADD CONSTRAINT fk_chebi_lipidmaps FOREIGN KEY(lipidmaps_id) REFERENCES lipidmaps_data (lipidmaps_id);
ALTER TABLE chebi_data ADD CONSTRAINT fk_chebi_pubchem FOREIGN KEY(pubchem_id) REFERENCES pubchem_data (pubchem_id);

-- HMDB
ALTER TABLE hmdb_data ADD CONSTRAINT fk_hmdb_kegg FOREIGN KEY(kegg_id) REFERENCES kegg_data (kegg_id);
ALTER TABLE hmdb_data ADD CONSTRAINT fk_hmdb_pubchem FOREIGN KEY(pubchem_id) REFERENCES pubchem_data (pubchem_id);
ALTER TABLE hmdb_data ADD CONSTRAINT fk_hmdb_chebi FOREIGN KEY(chebi_id) REFERENCES chebi_data (chebi_id);

-- KEGG
ALTER TABLE kegg_data ADD CONSTRAINT fk_kegg_chebi FOREIGN KEY(chebi_id) REFERENCES chebi_data (chebi_id);
ALTER TABLE kegg_data ADD CONSTRAINT fk_kegg_lipidmaps FOREIGN KEY(lipidmaps_id) REFERENCES lipidmaps_data (lipidmaps_id);
ALTER TABLE kegg_data ADD CONSTRAINT fk_kegg_pubchem FOREIGN KEY(pubchem_id) REFERENCES pubchem_data (pubchem_id);

-- LipidMaps
ALTER TABLE lipidmaps_data ADD CONSTRAINT fk_lipidmaps_kegg FOREIGN KEY(kegg_id) REFERENCES kegg_data (kegg_id);
ALTER TABLE lipidmaps_data ADD CONSTRAINT fk_lipidmaps_hmdb FOREIGN KEY(hmdb_id) REFERENCES hmdb_data (hmdb_id);
ALTER TABLE lipidmaps_data ADD CONSTRAINT fk_lipidmaps_chebi FOREIGN KEY(chebi_id) REFERENCES chebi_data (chebi_id);
ALTER TABLE lipidmaps_data ADD CONSTRAINT fk_lipidmaps_pubchem FOREIGN KEY(pubchem_id) REFERENCES pubchem_data (pubchem_id);

-- PubChem
ALTER TABLE pubchem_data ADD CONSTRAINT fk_pubchem_chebi FOREIGN KEY(chebi_id) REFERENCES chebi_data (chebi_id);
ALTER TABLE pubchem_data ADD CONSTRAINT fk_pubchem_kegg FOREIGN KEY(kegg_id) REFERENCES kegg_data (kegg_id);
ALTER TABLE pubchem_data ADD CONSTRAINT fk_pubchem_hmdb FOREIGN KEY(hmdb_id) REFERENCES hmdb_data (hmdb_id);
