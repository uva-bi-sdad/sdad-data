recreate_database <- function(db_name) {
  # create connection as your user - need permission to drop and create database
  con <- sdalr::con_db()
  # terminate open sessions on database
  DBI::dbGetQuery(con, sprintf("SELECT pg_terminate_backend (pid)
                                 FROM pg_stat_activity
                                 WHERE datname = '%s';", db_name))
  # drop database
  DBI::dbGetQuery(con, sprintf("DROP DATABASE %s;", db_name))
  # recreate database
  DBI::dbGetQuery(con, sprintf("CREATE DATABASE %s;", db_name))
  # reconnect to recreated database
  con <- sdalr::con_db(db_name)
  # enable GIS functions
  DBI::dbGetQuery(con, "CREATE EXTENSION postgis;")
}

recreate_database_permissions <- function(db_name) {
  # connect to database - need permission to create, drop and grant roles
  con <- sdalr::con_db(db_name)
  # create sdaldb_user role
  role_exists <- DBI::dbGetQuery(con, "SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = 'sdaldb_user'")
  if (nrow(role_exists) == 0) DBI::dbGetQuery(con, "CREATE ROLE sdaldb_user;")
  # grant select on all tables in all schemas to sdaldb_user role
  schemas <- 
    DBI::dbGetQuery(con, "select schema_name from information_schema.schemata where schema_owner <> 'postgres';")
  for (s in schemas$schema_name) DBI::dbGetQuery(con, sprintf("GRANT ALL ON SCHEMA %s TO sdaldb_user;", s))
  for (s in schemas$schema_name) DBI::dbGetQuery(con, sprintf("GRANT SELECT ON ALL TABLES IN SCHEMA %s TO sdaldb_user;", s))
  # grant sdaldb_user role to all users
  roles <- 
    DBI::dbGetQuery(con, "SELECT rolname FROM pg_roles WHERE rolname <> 'sdaldb_user'")
  for (r in roles$rolname) DBI::dbGetQuery(con, sprintf("GRANT sdaldb_user TO %s", r))
}