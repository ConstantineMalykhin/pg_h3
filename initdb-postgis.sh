#!/bin/bash

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
"${psql[@]}" <<- 'EOSQL'
CREATE DATABASE template_postgis IS_TEMPLATE true;
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
	echo "Loading PostGIS extensions into $DB"
	"${psql[@]}" --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS pg_trgm;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		-- Reconnect to update pg_setting.resetval
		-- See https://github.com/postgis/docker-postgis/issues/288
		\c
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;

		-- Create h3 extension
		CREATE EXTENSION h3;
		CREATE EXTENSION h3_postgis CASCADE;
		CREATE SCHEMA h3;

		CREATE TABLE h3.hex
		(
			ix H3INDEX NOT NULL PRIMARY KEY,
			resolution INT2 NOT NULL,
			-- v4 change: POLYGON to MULTIPOLYGON
			geom GEOMETRY (MULTIPOLYGON, 4326) NOT NULL,
			CONSTRAINT ck_resolution CHECK (resolution >= 0 AND resolution <= 15)
		);
		CREATE INDEX gix_h3_hex ON h3.hex USING GIST (geom);

		INSERT INTO h3.hex (ix, resolution, geom)
		SELECT ix, 0 AS resolution,
				-- v4 change: Wrapped in MULTI for consistent MULTIPOLYGON
				ST_Multi(h3_cell_to_boundary_geometry(ix)) AS geom
			FROM h3_get_res_0_cells() ix
		;

		INSERT INTO h3.hex (ix, resolution, geom)
		SELECT h3_cell_to_children(ix) AS ix,
				resolution + 1 AS resolution,
				-- v4 change: Wrapped in MULTI for consistent MULTIPOLYGON
				ST_Multi(h3_cell_to_boundary_geometry(h3_cell_to_children(ix)))
					AS geom
			FROM h3.hex 
			WHERE resolution IN (SELECT MAX(resolution) FROM h3.hex)
		;   
EOSQL
done