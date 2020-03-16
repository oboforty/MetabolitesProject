
CREATE TABLE secondary_id (
	db_tag VARCHAR(12) NOT NULL,
	secondary_id VARCHAR(20) NOT NULL,
	primary_id VARCHAR(20),
	PRIMARY KEY (db_tag, secondary_id)
)