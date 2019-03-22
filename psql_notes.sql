SELECT "GEOID" geoid, ST_SetSRID(ST_MakePoint(CAST("INTPTLON" AS double precision), CAST("INTPTLAT" AS double precision)), 4326) geometry
INTO tl_2018_51_bg_centerpoints
FROM tl_2018_51_bg;

SELECT "GEOID" geoid, ST_SetSRID(ST_MakePoint(CAST("INTPTLON" AS double precision), CAST("INTPTLAT" AS double precision)), 4326) geometry
INTO tl_2018_19_bg_centerpoints
FROM tl_2018_19_bg;

SELECT "GEOID" geoid, ST_SetSRID(ST_MakePoint(CAST("INTPTLON10" AS double precision), CAST("INTPTLAT10" AS double precision)), 4326) geometry
INTO tl_2018_51_block_centerpoints
FROM tl_2018_51_tabblock10;

SELECT "GEOID" geoid, ST_SetSRID(ST_MakePoint(CAST("INTPTLON10" AS double precision), CAST("INTPTLAT10" AS double precision)), 4326) geometry
INTO tl_2018_19_block_centerpoints
FROM tl_2018_19_tabblock10;

SELECT bg.geoid geoid_bg, b.geoid geoid_block, bg.geometry centerpoint_bg, b.geometry centerpoint_block
INTO tl_2018_51_bg_block_centerpoints
FROM tl_2018_51_bg_centerpoints bg
CROSS JOIN tl_2018_51_block_centerpoints b;

511539002023	0101000020E61000001D80C3FAF55053C02EC901BB9A544340
510030103001014	0101000020E61000005697F848EF9B53C01363997E890F4340
SELECT ST_Distance(0101000020E61000001D80C3FAF55053C02EC901BB9A544340, 0101000020E61000005697F848EF9B53C01363997E890F4340)


SELECT ST_Distance(geometry('0101000020E61000001D80C3FAF55053C02EC901BB9A544340')::geography, geometry('0101000020E61000005697F848EF9B53C01363997E890F4340')::geography)


ALTER TABLE tl_2018_51_bg_centerpoints ADD COLUMN geog geography(geometry);
UPDATE tl_2018_51_bg_centerpoints SET geog = ST_Transform(geometry, 4326);

--Distance in Meters
SELECT ST_Distance(st_transform((select geometry from tl_2018_51_bg_centerpoints limit 1), 900913), st_transform((select geometry from tl_2018_51_block_centerpoints limit 1), 900913));

-- Blocks within a mile of a block group center point
SELECT a.geoid geoid_bg, b.geoid geoid_block, ST_Distance(st_transform(a.geometry, 900913), st_transform(b.geometry, 900913)) dist_m
FROM tl_2018_51_bg_centerpoints a
JOIN tl_2018_51_block_centerpoints b
ON ST_Distance(st_transform(a.geometry, 900913), st_transform(b.geometry, 900913)) < 1609.344
WHERE a.geoid = '511539002023'

-- Blocks within a mile of a all block group center points in a tract
SELECT a.geoid geoid_bg, b.geoid geoid_block, ST_Distance(st_transform(a.geometry, 900913), st_transform(b.geometry, 900913)) dist_m
FROM tl_2018_51_bg_centerpoints a
JOIN tl_2018_51_block_centerpoints b
ON ST_Distance(st_transform(a.geometry, 900913), st_transform(b.geometry, 900913)) < 1609.344
WHERE a.geoid LIKE '51153900202%'


CREATE OR REPLACE FUNCTION bg_block_dist_m(geoid_bg text = '')
RETURNS TABLE(geoid_bg text, geoid_block text, dist_m double precision) AS $$
  SELECT a.geoid geoid_bg, b.geoid geoid_block, ST_Distance(ST_Transform(a.geometry::geometry, 900913), ST_Transform(b.geometry::geometry, 900913)) dist_m
FROM geospatial$census_tl.tl_2018_51_bg_centerpoints a
JOIN geospatial$census_tl.tl_2018_51_block_centerpoints b
ON ST_Distance(ST_Transform(a.geometry::geometry, 900913), ST_Transform(b.geometry::geometry, 900913)) < (5*1609.344)
WHERE a.geoid = $1
$$ language 'sql';


# Moving postgis fucntionbs
CREATE SCHEMA postgis;
ALTER DATABASE your_db_goes_here SET search_path="$user", public, postgis,topology;
GRANT ALL ON SCHEMA postgis TO public;
ALTER EXTENSION postgis SET SCHEMA postgis;
