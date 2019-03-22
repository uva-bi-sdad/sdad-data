# Create App Data View va_ct_evictions_00_16 ----------------------------------------------
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_ct_evictions_00_16")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_ct_evictions_00_16
  AS
  SELECT item_name, item_description, item_by, item_by_value, item_notes,
      item_geoid, item_geolevel, b.\"NAME\" item_geoname, c.\"NAMELSAD\" item_geoparent, item_year, item_last_update,
      data_set_name, data_set_category, data_set_sub_category, data_set_source,
      data_set_url, data_set_description, data_set_notes, data_set_last_update, data_set_keywords,
      item_measure, item_value, b.wkb_geometry, \"INTPTLAT\" ct_ctrpnt_lat, \"INTPTLON\" ct_ctrpnt_lon
    FROM economic_wellbeing$housing.us_evictions_00_16 e
    JOIN metadata.data_sets m on e.data_set_id = m.data_set_id
    JOIN geospatial$census_cb.cb_2016_us_county_500k b on e.item_geoid = b.\"GEOID\"
    JOIN geospatial$census_tl.tl_2017_us_county c on LEFT(e.item_geoid, 5) = c.\"GEOID\"
    WHERE e.item_name = 'evictions'
    AND e.item_geolevel = 'ct'
    AND b.\"STATEFP\" = '51'")

# Create App Data View va_ct_eviction_filings_00_16 ----------------------------------------------
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_ct_eviction_filings_00_16")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_ct_eviction_filings_00_16
  AS
  SELECT item_name, item_description, item_by, item_by_value, item_notes,
      item_geoid, item_geolevel, b.\"NAME\" item_geoname, c.\"NAMELSAD\" item_geoparent, item_year, item_last_update,
      data_set_name, data_set_category, data_set_sub_category, data_set_source,
      data_set_url, data_set_description, data_set_notes, data_set_last_update, data_set_keywords,
      item_measure, item_value, b.wkb_geometry, \"INTPTLAT\" ct_ctrpnt_lat, \"INTPTLON\" ct_ctrpnt_lon
    FROM economic_wellbeing$housing.us_evictions_00_16 e
    JOIN metadata.data_sets m on e.data_set_id = m.data_set_id
    JOIN geospatial$census_cb.cb_2016_us_county_500k b on e.item_geoid = b.\"GEOID\"
    JOIN geospatial$census_tl.tl_2017_us_county c on LEFT(e.item_geoid, 5) = c.\"GEOID\"
  WHERE e.item_name = 'eviction-filings'
  AND e.item_geolevel = 'ct'
  AND b.\"STATEFP\" = '51'")

# Create App Data View va_ct_eviction_rate_00_16 ----------------------------------------------
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_ct_eviction_rate_00_16")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_ct_eviction_rate_00_16
  AS
  SELECT item_name, item_description, item_by, item_by_value, item_notes,
      item_geoid, item_geolevel, b.\"NAME\" item_geoname, c.\"NAMELSAD\" item_geoparent, item_year, item_last_update,
      data_set_name, data_set_category, data_set_sub_category, data_set_source,
      data_set_url, data_set_description, data_set_notes, data_set_last_update, data_set_keywords,
      item_measure, item_value, b.wkb_geometry, \"INTPTLAT\" ct_ctrpnt_lat, \"INTPTLON\" ct_ctrpnt_lon
    FROM economic_wellbeing$housing.us_evictions_00_16 e
    JOIN metadata.data_sets m on e.data_set_id = m.data_set_id
    JOIN geospatial$census_cb.cb_2016_us_county_500k b on e.item_geoid = b.\"GEOID\"
    JOIN geospatial$census_tl.tl_2017_us_county c on LEFT(e.item_geoid, 5) = c.\"GEOID\"
  WHERE e.item_name = 'eviction-rate'
  AND e.item_geolevel = 'ct'
  AND b.\"STATEFP\" = '51'")

# Create App Data View va_ct_eviction_filing_rate_00_16 ----------------------------------------------
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_ct_eviction_filing_rate_00_16")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_ct_eviction_filing_rate_00_16
  AS
  SELECT item_name, item_description, item_by, item_by_value, item_notes,
      item_geoid, item_geolevel, b.\"NAME\" item_geoname, c.\"NAMELSAD\" item_geoparent, item_year, item_last_update,
      data_set_name, data_set_category, data_set_sub_category, data_set_source,
      data_set_url, data_set_description, data_set_notes, data_set_last_update, data_set_keywords,
      item_measure, item_value, b.wkb_geometry, \"INTPTLAT\" ct_ctrpnt_lat, \"INTPTLON\" ct_ctrpnt_lon
    FROM economic_wellbeing$housing.us_evictions_00_16 e
    JOIN metadata.data_sets m on e.data_set_id = m.data_set_id
    JOIN geospatial$census_cb.cb_2016_us_county_500k b on e.item_geoid = b.\"GEOID\"
    JOIN geospatial$census_tl.tl_2017_us_county c on LEFT(e.item_geoid, 5) = c.\"GEOID\"
  WHERE e.item_name = 'eviction-filing-rate'
  AND e.item_geolevel = 'ct'
  AND b.\"STATEFP\" = '51'")

# Create App Data View va_bg_evictions_00_16 ----------------------------------------------
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_bg_evictions_00_16")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
    "CREATE VIEW apps$dashboard.va_bg_evictions_00_16
    AS
    SELECT item_name, item_description, item_by, item_by_value, item_notes,
      item_geoid, item_geolevel, b.\"NAME\" item_geoname, c.\"NAMELSAD\" item_geoparent, item_year, item_last_update,
      data_set_name, data_set_category, data_set_sub_category, data_set_source,
      data_set_url, data_set_description, data_set_notes, data_set_last_update, data_set_keywords,
      item_measure, item_value, b.wkb_geometry, \"INTPTLAT\" ct_ctrpnt_lat, \"INTPTLON\" ct_ctrpnt_lon
    FROM economic_wellbeing$housing.us_evictions_00_16 e
    JOIN metadata.data_sets m on e.data_set_id = m.data_set_id
    JOIN geospatial$census_cb.cb_2016_51_bg_500k b on e.item_geoid = b.\"GEOID\"
    JOIN geospatial$census_tl.tl_2017_us_county c on LEFT(e.item_geoid, 5) = c.\"GEOID\"
    WHERE e.item_name = 'evictions'
    AND e.item_geolevel = 'bg'"
  )

# Create App Data View va_bg_eviction_filings_00_16 ----------------------------------------------
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_bg_eviction_filings_00_16")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
    "CREATE VIEW apps$dashboard.va_bg_eviction_filings_00_16
    AS
    SELECT item_name, item_description, item_by, item_by_value, item_notes,
      item_geoid, item_geolevel, b.\"NAME\" item_geoname, c.\"NAMELSAD\" item_geoparent, item_year, item_last_update,
      data_set_name, data_set_category, data_set_sub_category, data_set_source,
      data_set_url, data_set_description, data_set_notes, data_set_last_update, data_set_keywords,
      item_measure, item_value, b.wkb_geometry, \"INTPTLAT\" ct_ctrpnt_lat, \"INTPTLON\" ct_ctrpnt_lon
    FROM economic_wellbeing$housing.us_evictions_00_16 e
    JOIN metadata.data_sets m on e.data_set_id = m.data_set_id
    JOIN geospatial$census_cb.cb_2016_51_bg_500k b on e.item_geoid = b.\"GEOID\"
    JOIN geospatial$census_tl.tl_2017_us_county c on LEFT(e.item_geoid, 5) = c.\"GEOID\"
    WHERE e.item_name = 'eviction-filings'
    AND e.item_geolevel = 'bg'")

# Create App Data View va_bg_eviction_rate_00_16 ----------------------------------------------
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_bg_eviction_rate_00_16")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
    "CREATE VIEW apps$dashboard.va_bg_eviction_rate_00_16
    AS
    SELECT item_name, item_description, item_by, item_by_value, item_notes,
      item_geoid, item_geolevel, b.\"NAME\" item_geoname, c.\"NAMELSAD\" item_geoparent, item_year, item_last_update,
      data_set_name, data_set_category, data_set_sub_category, data_set_source,
      data_set_url, data_set_description, data_set_notes, data_set_last_update, data_set_keywords,
      item_measure, item_value, b.wkb_geometry, \"INTPTLAT\" ct_ctrpnt_lat, \"INTPTLON\" ct_ctrpnt_lon
    FROM economic_wellbeing$housing.us_evictions_00_16 e
    JOIN metadata.data_sets m on e.data_set_id = m.data_set_id
    JOIN geospatial$census_cb.cb_2016_51_bg_500k b on e.item_geoid = b.\"GEOID\"
    JOIN geospatial$census_tl.tl_2017_us_county c on LEFT(e.item_geoid, 5) = c.\"GEOID\"
    WHERE e.item_name = 'eviction-rate'
    AND e.item_geolevel = 'bg'")

# Create App Data View va_bg_eviction_filing_rate_00_16 ----------------------------------------------
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_bg_eviction_filing_rate_00_16")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
    "CREATE VIEW apps$dashboard.va_bg_eviction_filing_rate_00_16
    AS
    SELECT item_name, item_description, item_by, item_by_value, item_notes,
      item_geoid, item_geolevel, b.\"NAME\" item_geoname, c.\"NAMELSAD\" item_geoparent, item_year, item_last_update,
      data_set_name, data_set_category, data_set_sub_category, data_set_source,
      data_set_url, data_set_description, data_set_notes, data_set_last_update, data_set_keywords,
      item_measure, item_value, b.wkb_geometry, \"INTPTLAT\" ct_ctrpnt_lat, \"INTPTLON\" ct_ctrpnt_lon
    FROM economic_wellbeing$housing.us_evictions_00_16 e
    JOIN metadata.data_sets m on e.data_set_id = m.data_set_id
    JOIN geospatial$census_cb.cb_2016_51_bg_500k b on e.item_geoid = b.\"GEOID\"
    JOIN geospatial$census_tl.tl_2017_us_county c on LEFT(e.item_geoid, 5) = c.\"GEOID\"
    WHERE e.item_name = 'eviction-filing-rate'
    AND e.item_geolevel = 'bg'")
