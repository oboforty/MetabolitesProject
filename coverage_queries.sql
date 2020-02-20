
-- HMDB / CHEBI
-- 6117
SELECT count(*) FROM hmdb_data h, chebi_data c WHERE h.chebi_id = c.chebi_id AND h.chebi_id IS NOT NULL
-- 3893
SELECT count(*) FROM hmdb_data h, chebi_data c WHERE h.hmdb_id = c.hmdb_id AND c.hmdb_id IS NOT NULL
-- 45297
SELECT count(*) FROM hmdb_data h, chebi_data c WHERE h.names && c.names


-- HMDB / LipidMaps
-- 4510
SELECT count(*) FROM hmdb_data h, lipidmaps_data l WHERE h.hmdb_id = l.hmdb_id AND h.hmdb_id IS NOT NULL


-- CHEBI / LipidMaps
-- 2861
SELECT count(*) FROM chebi_data c, lipidmaps_data l WHERE c.lipidmaps_id = l.lipidmaps_id AND c.lipidmaps_id IS NOT NULL
-- 1946
SELECT count(*) FROM chebi_data c, lipidmaps_data l WHERE c.chebi_id = l.chebi_id AND c.chebi_id IS NOT NULL
--




-- NAMES:
SELECT count(*) FROM (
	SELECT h.chebi_id FROM hmdb_data h, chebi_data c WHERE h.names && c.names GROUP BY h.chebi_id
) as kurva


SELECT count(*) FROM (
	SELECT l.hmdb_id FROM hmdb_data h, lipidmaps_data l WHERE h.names && l.names GROUP BY l.hmdb_id
) as kurva

-- SMILES:
-- 42
SELECT count(*) FROM hmdb_data h, chebi_data c
WHERE h.smiles = c.smiles
AND c.hmdb_id IS NOT NULL AND h.chebi_id IS NOT NULL
AND (h.hmdb_id != c.hmdb_id or h.chebi_id != c.chebi_id)

-- 740
SELECT count(*) FROM hmdb_data h, chebi_data c
WHERE h.smiles = c.smiles
AND c.hmdb_id IS NOT NULL AND h.chebi_id IS NOT NULL
AND (h.hmdb_id = c.hmdb_id AND h.chebi_id = c.chebi_id)


-- FORMULA:



-- 42
SELECT count(*) FROM hmdb_data h, chebi_data c
WHERE h.smiles = c.smiles
AND c.hmdb_id IS NOT NULL AND h.chebi_id IS NOT NULL
AND (h.hmdb_id != c.hmdb_id or h.chebi_id != c.chebi_id)

-- 740
SELECT count(*) FROM hmdb_data h, chebi_data c
WHERE h.smiles = c.smiles
AND c.hmdb_id IS NOT NULL AND h.chebi_id IS NOT NULL
AND (h.hmdb_id = c.hmdb_id AND h.chebi_id = c.chebi_id)
