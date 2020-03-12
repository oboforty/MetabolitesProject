-- (column_name [ASC | DESC] [NULLS {FIRST | LAST }], );
-- todo: add CONCURRENTLY?

-- Chebi
CREATE INDEX ON chebi_data USING btree (kegg_id);
CREATE INDEX ON chebi_data USING btree (hmdb_id);
CREATE INDEX ON chebi_data USING btree (lipidmaps_id);
CREATE INDEX ON chebi_data USING btree (pubchem_id);

-- HMDB
CREATE INDEX ON hmdb_data USING btree (kegg_id);
CREATE INDEX ON hmdb_data USING btree (pubchem_id);
CREATE INDEX ON hmdb_data USING btree (chebi_id);

-- KEGG
CREATE INDEX ON kegg_data USING btree (chebi_id);
CREATE INDEX ON kegg_data USING btree (lipidmaps_id);
CREATE INDEX ON kegg_data USING btree (pubchem_id);

-- LipidMaps
CREATE INDEX ON lipidmaps_data USING btree (kegg_id);
CREATE INDEX ON lipidmaps_data USING btree (hmdb_id);
CREATE INDEX ON lipidmaps_data USING btree (chebi_id);
CREATE INDEX ON lipidmaps_data USING btree (pubchem_id);

-- PubChem
CREATE INDEX ON pubchem_data USING btree (chebi_id);
CREATE INDEX ON pubchem_data USING btree (kegg_id);
CREATE INDEX ON pubchem_data USING btree (hmdb_id);
