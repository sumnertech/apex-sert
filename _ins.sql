-- main installer

-- create users
@@schemas/_ins_schemas.sql

-- SERT_CORE
alter session set current_schema = sert_core;

-- install tables
@@schemas/sert_core/tables/_ins_tables.sql

-- install views
@@schemas/sert_core/views/_ins_views.sql

-- install packages
@@schemas/sert_core/pkg/_ins_pkg.sql

-- install seed data
@@schemas/sert_core/seed/_ins_seed.sql

-- install grants
@@schemas/sert_core/grants/_ins_grants.sql


-- SERT_PUB
alter session set current_schema = sert_pub;

