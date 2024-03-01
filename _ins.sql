--    NAME
--      ins.sql
--
--    DESCRIPTION
--
--    NOTES
--      - Requires a user with DBA privileges to be connected. 
--
--    Arguments:
--
--    Example:
--
--    1)Local
--      sqlplus "sys/syspass as sysdba" @ins 
--
--    2)With connect string
--      sqlplus "sys/syspass@10g as sysdba" @ins 
--
--    MODIFIED   
--      dgault 02/28/2024  - Created   
--      
--  TERMOUT  - Set terminal output on. We went to see it. 
set termout on
--  feedback - Displays the number of records returned by a script ON=1
set feedback off
-- serverout - allow dbms_output.put_line to be seen in sqlplus
set serverout on
--  define on -- allows substitutions
set define on
--  define - Sets the character used to prefix substitution variables
set define '^'
--  concat - Sets the character used to terminate a substitution variable ON=.
set concat on 
set concat .
--  verify off prevents the old/new substitution message
set verify on
--Sets the number of lines on each page of output.
SET PAGESIZE 50

CLEAR SCREEN
PROMPT .  
PROMPT .            _____  ________   __     _____ ______ _____ _______ 
PROMPT .      /\   |  __ \|  ____\ \ / /    / ____|  ____|  __ \__   __|
PROMPT .     /  \  | |__) | |__   \ V /____| (___ | |__  | |__) | | |   
PROMPT .    / /\ \ |  ___/|  __|   > <______\___ \|  __| |  _  /  | |   
PROMPT .   / ____ \| |    | |____ / . \     ____) | |____| | \ \  | |   
PROMPT .  /_/    \_\_|    |______/_/ \_\   |_____/|______|_|  \_\ |_|   
PROMPT .                            
PROMPT  ========================== APEX-SERT ============================
PROMPT 
PAUSE   Press Enter to continue installation or CTRL-C to EXIT
--
-- Terminate the script on Error during the beginning
whenever sqlerror exit

--  =================
--  =================  User Input and Substitution Varible Definitions
--  =================
define sdb2                        = 'FALSE'                 
define create_parse_as_s           = 'ins/create_parse_as.sql'
define scheduling_grant_s          = 'ins/scheduling_grant.sql'
define parse_as_grants_s           = 'ins/parse_as_grants.sql'
define app_id_assign_script         ='app/id_prompts.sql'       -- Script to assign APP_ID

PROMPT  ... Testing for prerequisites
--  =================
--  =================  PREREQUISITE TESTS
--  =================
--
--  =================
--  =================  Check Appropriate Privileges are present
--  =================
PROMPT  ...... Test for required privs
declare
l_privs varchar2(5) := 'FALSE';
--
begin 
-- 
WITH required_privileges AS (
  SELECT 'CREATE USER' AS PRIVILEGE FROM dual -- Creation of the SERT users
  UNION ALL
  SELECT 'GRANT ANY ROLE' AS PRIVILEGE FROM dual -- Grant APEX_ADMINISTRATOR_ROLE
  UNION ALL
  SELECT 'ALTER USER' AS PRIVILEGE FROM dual -- Grant alter user to give Unlimited tablespace
),
matching_privileges AS (
  SELECT COUNT(DISTINCT rp.PRIVILEGE) AS matched_count
  FROM required_privileges rp
  JOIN SESSION_PRIVS sp ON rp.PRIVILEGE = sp.PRIVILEGE
)
SELECT CASE 
         WHEN (SELECT matched_count FROM matching_privileges) = (SELECT COUNT(*) FROM required_privileges) THEN 'TRUE'
         ELSE 'FALSE'
       END AS sdb
  into l_privs
FROM dual;
--
--
    if l_privs = 'FALSE' then
        dbms_output.put_line('SERT installation requires a connection with the following privileges.');
        dbms_output.put_line(' - CREATE USER');
        dbms_output.put_line(' - GRANT ANY ROLE');
        dbms_output.put_line(' - ALTER USER');
        execute immediate 'bogus statement to force exit';
    else 
        dbms_output.put_line('........ PASSED');
    end if;
end;
/
--  =================
--  =================  Check for V12.1.0.2  and above of the databse
--  =================
PROMPT  ...... Test for Oracle 12.1.0.2 or above

declare
    l_version number;
begin
    execute immediate
      'select to_number(replace(version_full,''.'',null)) from dba_registry where COMP_ID=''CATPROC'''
    into l_version;

    if l_version < 121020  then
        dbms_output.put_line('SERT installation requires database version 12.1.0.2  or later.');
        execute immediate 'bogus statement to force exit';
    else 
        dbms_output.put_line('........ PASSED');
    end if;
    EXCEPTION
       when others then
          dbms_output.put_line('Error Selecting data from DBA_REGISTRY ');
          dbms_output.put_line(SQLERRM);
         execute immediate 'bogus statement to force exit'; 
end;
/


--  =================
--  =================  Check for APEX 23.2.0 or above
--  =================
PROMPT  ...... Test for Valid Instance of APEX 23.2.0 or above
declare
    l_version number;
    l_status dba_registry.status%TYPE := 'INVALID';
begin
    BEGIN 
       execute immediate
         'select to_number(replace(version_full,''.'',null)), status from DBA_REGISTRY where COMP_ID = ''APEX'''
       into l_version, l_status;
    EXCEPTION
       when NO_DATA_FOUND then
         dbms_output.put_line('SERT installation requires a VALID APEX installation of Version 23.2.0 or above.');
          dbms_output.put_line('-- NO APEX INSTALLATION FOUND IN DBA_REGISTRY.');
          execute immediate 'bogus statement to force exit';
       when others then
          dbms_output.put_line('Error Selecting data from DBA_REGISTRY ');
          dbms_output.put_line(SQLERRM);
         execute immediate 'bogus statement to force exit'; 
    END; 
    
    if l_version < 2320 then
        dbms_output.put_line('SERT installation requires APEX version 23.2.0 or later.');
        execute immediate 'bogus statement to force exit';
    elsif l_status = 'INVALID' then
        dbms_output.put_line('Current version of APEX is marked as INVALID.');
        execute immediate 'bogus statement to force exit';
    else 
        dbms_output.put_line('........ PASSED');
    end if;

end;
/
--  =================
--  =================  END PREREQUISITE TESTS
--  =================
PROMPT  ... Test for prerequisites succeeded
PROMPT

whenever sqlerror continue
--  =================
--  ================= Start The logging 
--  ================= 
column log_name new_val logname NOPRINT
select 'SERT_install_'||to_char(sysdate, 'YYYY-MM-DD_HH24-MI-SS')||'.log' log_name from dual;
-- Spool the log
spool ^logname

PROMPT 
PROMPT .. 
PROMPT .. Checking to see if SERT User already exist. 
PROMPT .. 
PROMPT 

-- Hide the output of the sql statement since NOPRINT doesn't work=
set termout off 
column create_user_script new_val create_user_s NOPRINT
--
with sert_users as (
    select 1 ct from dba_users where username = 'SERT_CORE'
    UNION ALL 
    select 1 ct from dba_users where username = 'SERT_PUB'
    UNION ALL 
    select 1  ct from dba_users where username = 'SERT_REST'
), 
 user_count as (
    select sum(ct) tot_ct from sert_users 
 )
select  case when tot_ct = 3 then 'good_install.sql' 
             when tot_ct > 0 and tot_ct < 3 then 'bad_install.sql' 
             else 'schemas/_ins_schemas.sql'
        end create_user_script
 from user_count;

set termout on
--
-- Create the SERT Users and grants.
-- 
@@^create_user_s

set termout on
PROMPT
PROMPT ==================================================================================
PROMPT = Switching to SERT_CORE schema to install objects 
PROMPT ==================================================================================
PROMPT 
alter session set current_schema = sert_core;
--
-- - install tables
@schemas/sert_core/tables/_ins_tables.sql
-- 
-- - install views
@schemas/sert_core/views/_ins_views.sql
-- 
-- - install packages
@schemas/sert_core/pkg/_ins_pkg.sql
-- 
-- - install grants
@schemas/sert_core/grants/_ins_grants.sql
--
-- - install seed data
@schemas/sert_core/seed/_ins_seed.sql

set termout on
PROMPT
PROMPT ==================================================================================
PROMPT = Switching to SERT_PUB schema to install objects 
PROMPT ==================================================================================
PROMPT 
alter session set current_schema = sert_pub;
-- - install views
@schemas/sert_pub/views/_ins_views.sql
-- 
-- - install synonyms
@schemas/sert_pub/synonyms/_ins_synonyms.sql


-- reset the define variable
set define '&'

<<<<<<< HEAD
--  =================
--  =================  Reset all of the standard settings
--  =================
set termout on
set feedback on
Set verify on
whenever sqlerror continue
--  =================
--  =================  END OF INSTALLATION
--  =================
PROMPT
PROMPT
PROMPT  =================================== SERT ==================================
PROMPT
PROMPT  Please check the log file for errors. 
PROMPT  
PROMPT
PROMPT  ============================================================================
PROMPT  ============================= C O M P L E T E ==============================
PROMPT  ============================================================================
spool off
=======
-- install grants
@@schemas/sert_core/grants/_ins_grants.sql

-- SERT_PUB
-- install views
@@schemas/sert_pub/views/_ins_views.sql

-- install synonyms
@@schemas/sert_pub/synonyms/_ins_synonyms.sql

-- install seed data
@@schemas/sert_core/seed/_ins_seed.sql
>>>>>>> a4f19940135130129934d34baa71269c663a0ea0
