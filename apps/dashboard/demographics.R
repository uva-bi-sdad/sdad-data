# Create App Data View va_bg_pop_by_sex_15 ----------------------------------------------
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_bg_pop_by_sex_15")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_bg_pop_by_sex_15
  AS
  SELECT item_name, item_description, item_by, item_by_value, item_notes,
        item_geoid, item_geolevel, b.\"NAME\" item_geoname, c.\"NAMELSAD\" item_geoparent, item_year,
        data_set_name, data_set_category, data_set_sub_category, data_set_source,
        data_set_url, data_set_description, data_set_notes, data_set_last_update, data_set_keywords,
        item_measure, item_value, b.wkb_geometry, \"INTPTLAT\" ct_ctrpnt_lat, \"INTPTLON\" ct_ctrpnt_lon
  FROM demographics$population.va_bg_pop_by_sex_15 e
  JOIN metadata.data_sets m on e.data_set_id = m.data_set_id
  JOIN geospatial$census_tl.tl_2017_us_county c on LEFT(e.item_geoid, 5) = c.\"GEOID\"
  JOIN geospatial$census_cb.cb_2016_51_bg_500k b on e.item_geoid = b.\"GEOID\"
  WHERE b.\"STATEFP\" = '51'")

# Create App Data View va_bg_pop_by_sex_15 ----------------------------------------------
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_bg_pop_by_sex_and_age_15")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_bg_pop_by_sex_and_age_15
  AS
  SELECT item_name, item_description, item_by, item_by_value, item_notes,
        item_geoid, item_geolevel, b.\"NAME\" item_geoname, c.\"NAMELSAD\" item_geoparent, item_year,
        data_set_name, data_set_category, data_set_sub_category, data_set_source,
        data_set_url, data_set_description, data_set_notes, data_set_last_update, data_set_keywords,
        item_measure, item_value, b.wkb_geometry, \"INTPTLAT\" ct_ctrpnt_lat, \"INTPTLON\" ct_ctrpnt_lon
  FROM demographics$population.va_bg_pop_by_sex_and_age_15 e
  JOIN metadata.data_sets m on e.data_set_id = m.data_set_id
  JOIN geospatial$census_tl.tl_2017_us_county c on LEFT(e.item_geoid, 5) = c.\"GEOID\"
  JOIN geospatial$census_cb.cb_2016_51_bg_500k b on e.item_geoid = b.\"GEOID\"
  WHERE b.\"STATEFP\" = '51'")

# Create App Data View va_bg_hshlds_by_inc_15 ----------------------------------------------
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_bg_hshlds_by_inc_15")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_bg_hshlds_by_inc_15
  AS
  SELECT item_name, item_description, item_by, item_by_value, item_notes,
        item_geoid, item_geolevel, b.\"NAME\" item_geoname, c.\"NAMELSAD\" item_geoparent, item_year,
        data_set_name, data_set_category, data_set_sub_category, data_set_source,
        data_set_url, data_set_description, data_set_notes, data_set_last_update, data_set_keywords,
        item_measure, item_value, b.wkb_geometry, \"INTPTLAT\" ct_ctrpnt_lat, \"INTPTLON\" ct_ctrpnt_lon
  FROM demographics$housing.va_bg_hshlds_by_inc_15 e
  JOIN metadata.data_sets m on e.data_set_id = m.data_set_id
  JOIN geospatial$census_tl.tl_2017_us_county c on LEFT(e.item_geoid, 5) = c.\"GEOID\"
  JOIN geospatial$census_cb.cb_2016_51_bg_500k b on e.item_geoid = b.\"GEOID\"
  WHERE b.\"STATEFP\" = '51'")
