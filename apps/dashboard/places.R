# Virginia Public Schools
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_pl_public_schools")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
"CREATE VIEW apps$dashboard.va_pl_public_schools
 AS
 SELECT \"NAME\" item_name,
       'Address: ' || \"ADDRESS\" || ', ' || \"CITY\" || ', ' || \"STATE\" || ', ' || \"ZIP\" || '<br />'
       'Level: ' || \"LEVEL_\" || '<br />'
       'Enrollment: ' || \"ENROLLMENT\" || '<br />'
       'Full-Time Teachers: ' || \"FT_TEACHER\" || '<br />'
       'Website: ' || \"WEBSITE\" item_description,
       'pl' item_geolevel,
       geometry wkb_geometry
FROM geospatial$places.us_pl_public_schools
WHERE \"STATE\" = 'VA'")

# Virginia Private Schools
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_pl_private_schools")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_pl_private_schools
 AS
 SELECT \"NAME\" item_name,
       'Address: ' || \"ADDRESS\" || ', ' || \"CITY\" || ', ' || \"STATE\" || ', ' || \"ZIP\" || '<br />'
       'Level: ' || \"LEVEL_\" || '<br />'
       'Enrollment: ' || \"ENROLLMENT\" || '<br />'
       'Full-Time Teachers: ' || \"FULL_TIME_\" || '<br />'
       'Website: ' || \"SOURCE\" item_description,
       'pl' item_geolevel,
       geometry wkb_geometry
FROM geospatial$places.us_pl_private_schools
WHERE \"STATE\" = 'VA'")

# Virginia Hospitals
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_pl_hospitals")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_pl_hospitals
 AS
 SELECT \"NAME\" item_name,
       'Address: ' || \"ADDRESS\" || ', ' || \"CITY\" || ', ' || \"STATE\" || ', ' || \"ZIP\" || '<br />'
       'Phone: ' || \"TELEPHONE\" || '<br />'
       'NAICS Description: ' || \"NAICS_DESC\" || '<br />'
       'Owner Type: ' || \"OWNER\" || '<br />'
       'Trauma: ' || \"TRAUMA\" || '<br />'
       'Helipad: ' || \"HELIPAD\" || '<br />'
       'Website: ' || \"WEBSITE\" item_description,
       'pl' item_geolevel,
       geometry wkb_geometry
FROM geospatial$places.us_pl_hospitals
WHERE \"STATE\" = 'VA'")

# Virginia Urgent Care Facilities
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_pl_urgent_care_facilities")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_pl_urgent_care_facilities
 AS
 SELECT \"NAME\" item_name,
       'Address: ' || \"ADDRESS\" || ', ' || \"CITY\" || ', ' || \"STATE\" || ', ' || \"ZIP\" || '<br />'
       'Phone: ' || \"TELEPHONE\" || '<br />'
       'NAICS Description: ' || \"NAICSDESCR\" || '<br />'
       'Directions: ' || \"DIRECTIONS\" item_description,
       'pl' item_geolevel,
       geometry wkb_geometry
FROM geospatial$places.us_pl_urgent_care_facilities
WHERE \"STATE\" = 'VA'")

# Virginia Pharmacies
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_pl_pharmacies")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_pl_pharmacies
 AS
 SELECT \"NAME\" item_name,
       'Address: ' || \"ADDRESS\" || ', ' || \"CITY\" || ', ' || \"STATE\" || ', ' || \"ZIP\" || '<br />'
       'Phone: ' || \"TELEPHONE\" || '<br />'
       'Website: ' || \"WEBSITE\" item_description,
       'pl' item_geolevel,
       geometry wkb_geometry
FROM geospatial$places.us_pl_pharmacies
WHERE \"STATE\" = 'VA'")

# Virginia Places of Worship
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_pl_places_of_worship")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_pl_places_of_worship
 AS
 SELECT \"NAME\" item_name,
       'Type: ' || \"SUBTYPE\" || ' ' || \"DENOM\" || '<br />'
       'Address: ' || \"ADDRESS\" || ', ' || \"CITY\" || ', ' || \"STATE\" || ', ' || \"ZIP\" || '<br />'
       'Phone: ' || \"TELEPHONE\" || '<br />'
       'NAICS Description: ' || \"NAICSDESCR\" item_description,
       'pl' item_geolevel,
       geometry wkb_geometry
FROM geospatial$places.us_pl_places_of_worship
WHERE \"STATE\" = 'VA'")

# Virginia Mobile Home Parks
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_pl_mobile_home_parks")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_pl_mobile_home_parks
 AS
 SELECT \"NAME\" item_name,
       'Type: ' || \"TYPE\" || '<br />'
       'Address: ' || \"ADDRESS\" || ', ' || \"CITY\" || ', ' || \"STATE\" || ', ' || \"ZIP\" || '<br />'
       'Phone: ' || \"TELEPHONE\" || '<br />'
       'NAICS Description: ' || \"NAICS_DESC\" item_description,
       'pl' item_geolevel,
       geometry wkb_geometry
FROM geospatial$places.us_pl_mobile_home_parks
WHERE \"STATE\" = 'VA'")

# Virginia SNAP Providers
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_pl_snap_providers")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_pl_snap_providers
 AS
 SELECT \"Store_Name\" item_name,
       'Address: ' || \"Address\" || ', ' || \"City\" || ', ' || \"State\" || ', ' || \"Zip5\" || '<br />'
       'Source: ' || \"source\" item_description,
       'pl' item_geolevel,
       geoid item_geoid,
       geometry
FROM geospatial$places.us_pl_snap_providers
WHERE \"State\" = 'VA'")

# Virginia Mining Operations
DBI::dbGetQuery(sdalr::con_db("sdal"), "create schema if not exists apps$dashboard")
DBI::dbGetQuery(sdalr::con_db("sdal"), "drop view if exists apps$dashboard.va_pl_mining_operations")
DBI::dbGetQuery(
  sdalr::con_db("sdal"),
  "CREATE VIEW apps$dashboard.va_pl_mining_operations
 AS
 SELECT item_name,
       'Name: ' || item_name || '<br />Status: ' || item_status || '<br />Type: ' || current_mine_type || '<br />Primary SIC: ' || primary_sic || '<br />Primary Canvass: ' || primary_canvass || '</br />Employees: ' || no_employees item_description,
       'pl' item_geolevel,
       item_geoid,
       geometry
FROM geospatial$places.va_pl_mining_operations_17")

