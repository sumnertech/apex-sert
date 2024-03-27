--    NAME
--      _ins_schemas.sql
--
--    DESCRIPTION
--
--
--    Arguments:
--
--    MODIFIED   (MM/DD/YYYY)
--      dgault    02/28/2024  - Created

set termout on
set define '^'
set concat on
set concat .
set verify off
--
--
PROMPT
PROMPT ==================================================================================
PROMPT = CREATING SERT SCHEMAS
PROMPT ==================================================================================
PROMPT
PROMPT - Users being created will be
PROMPT - SERT_CORE
PROMPT - SERT_PUB
PROMPT - SERT_REST
PROMPT
PROMPT
PROMPT
ACCEPT schema_password     CHAR DEFAULT ''  PROMPT 'Please enter the password for the SERT Schemas: '
PROMPT
PROMPT Listing all available tablespaces...
PROMPT
select tablespace_name "Tablespace Name" from dba_tablespaces ORDER BY 1;
--
PROMPT
ACCEPT dflt CHAR DEFAULT 'users' PROMPT 'Please enter the default tablespace to be used for the above schemas [USERS] : '
ACCEPT temp CHAR DEFAULT 'temp'  PROMPT 'Please enter the temporary tablespace to be used for the above schemas [TEMP] : '
--
set feedback on

create user sert_pub  identified by "^schema_password" default tablespace ^dflt quota unlimited on ^dflt temporary tablespace ^temp;
create user sert_core identified by "^schema_password" default tablespace ^dflt quota unlimited on ^dflt temporary tablespace ^temp;
create user sert_rest identified by "^schema_password" default tablespace ^dflt quota unlimited on ^dflt temporary tablespace ^temp;
PROMPT
PROMPT Granting APEX_ADMINISTRATOR_ROLE to SERT_CORE
PROMPT
grant apex_administrator_read_role to sert_core;
PROMPT
PROMPT Granting APEX_ADMINISTRATOR_ROLE to SERT_PUB
PROMPT
grant apex_administrator_read_role to sert_pub;
PROMPT
PROMPT Schema Creation Complete...
PROMPT
set feedback off;
set termout off;
