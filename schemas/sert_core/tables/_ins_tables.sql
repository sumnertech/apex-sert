--    NAME
--      _ins_tables.sql
--
--    DESCRIPTION
--      install tables in the SERT_CORE schema
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
PROMPT = CREATING TABLES IN SERT_CORE
PROMPT ==================================================================================
PROMPT 
@@schemas/sert_core/tables/tables.sql