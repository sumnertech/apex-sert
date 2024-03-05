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

PROMPT  ==================================================================
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

PROMPT   =================
PROMPT   =================  P R E R E Q U I S I T E   T E S T S
PROMPT   =================
PROMPT 
PROMPT  =================
PROMPT  =================  Check Appropriate Privileges are present
PROMPT  =================
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
PROMPT  =================
PROMPT  =================  Check for V12.1.0.2  and above of the databse
PROMPT  =================

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


PROMPT  =================
PROMPT  =================  Check for APEX 23.2.0 or above
PROMPT  =================
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
PROMPT  =================
PROMPT  =================  E N D   P R E R E Q U I S I T E   T E S T S
PROMPT  =================
PROMPT 

-- House Keeping 
-- Get the CURRENT USER for use later
column logged_in_user new_val curr_user NOPRINT
select sys_context('USERENV','CURRENT_USER') LOGGED_IN_USER
from dual;
--
whenever sqlerror continue
PROMPT  =================
PROMPT  ================= Start The logging 
PROMPT  ================= 
PROMPT

column log_name new_val logname NOPRINT
select 'SERT_install_'||to_char(sysdate, 'YYYY-MM-DD_HH24-MI-SS')||'.log' log_name from dual;
-- Spool the log
spool ^logname

PROMPT =================
PROMPT .. 
PROMPT .. Checking to see if SERT Users already exist. 
PROMPT .. 
PROMPT =================

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
select  case when tot_ct = 3 then 'scripts/good_install.sql' 
             when tot_ct > 0 and tot_ct < 3 then 'scripts/bad_install.sql' 
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
-- .. TABLES
@schemas/sert_core/tables/_ins_tables.sql
-- 
-- .. VIEWS
@schemas/sert_core/views/_ins_views.sql
-- 
-- .. PACKAGES
@schemas/sert_core/pkg/_ins_pkg.sql
-- 
-- .. GRANTS
@schemas/sert_core/grants/_ins_grants.sql
--
PROMPT .. SEED DATA
@schemas/sert_core/seed/_ins_seed.sql

set termout on
PROMPT
PROMPT ==================================================================================
PROMPT = Switching to SERT_PUB schema to install objects 
PROMPT ==================================================================================
PROMPT 
alter session set current_schema = sert_pub;
-- .. VIEWS 
@schemas/sert_pub/views/_ins_views.sql
-- 
-- .. SYNONYMS 
@schemas/sert_pub/synonyms/_ins_synonyms.sql

PROMPT
PROMPT ==================================================================================
PROMPT = Switching back to  ^curr_user schema to install APEX objects 
PROMPT ==================================================================================
PROMPT 
alter session set current_schema = ^curr_user;

PROMPT  =============================================================================
PROMPT  == WORKSPACE AND APPLICATIONS INSTALL 
PROMPT  =============================================================================
PROMPT 
ACCEPT ws_password  CHAR DEFAULT '' PROMPT 'Please enter a password for the SERT Workspace ADMIN user: '
ACCEPT ws_email     CHAR DEFAULT '' PROMPT 'Please enter an email address for the SERT Workspace ADMIN user: '
PROMPT
PROMPT  =================
PROMPT  ================= CREATING WORKSPACE 
PROMPT  ================= 
PROMPT

 DECLARE
  l_workspace   varchar2(20)  := 'SERT';
  l_workspace_id  number;
BEGIN

  -- Run the creation steps
  dbms_output.put_line('== Creating Workspace: '|| l_workspace);

  -- Set the APEX session
  wwv_flow_api.set_security_group_id(10);

  -- Create the workspace
  APEX_INSTANCE_ADMIN.ADD_WORKSPACE(
      p_workspace           => l_workspace,
      p_primary_schema      => 'SERT_CORE',
      p_additional_schemas  => 'SERT_PUB:SERT_REST'
      );
  
  -- remove line to not enable the workspace
  apex_instance_admin.enable_workspace(l_workspace);     
  
  -- Save the new workspace
  COMMIT;

  dbms_output.put_line('== Workspace Created');
  dbms_output.put_line('== .. Workspace Name : '||l_workspace);

  -- get the new ID so we can use the security grup
  select workspace_id
    into l_workspace_id
    from apex_workspaces
    where workspace = l_workspace;
  
  -- set the security group to add user to
  apex_util.set_security_group_id(p_security_group_id => l_workspace_id);

  -- add default user..
  APEX_UTIL.CREATE_USER(
          p_user_name                     => 'ADMIN'
         ,p_web_password                  => '^ws_password'
         ,p_email_address                 => '^ws_email'
         ,p_developer_privs               => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL'
         ,p_default_schema                => 'SERT_CORE'
         ,p_change_password_on_first_use  => 'N');

  -- be sure to save changes
  COMMIT;

  dbms_output.put_line('== ADMIN User Created');
  dbms_output.put_line('== .. User Name : ADMIN');
  dbms_output.put_line('== .. Password  : ^ws_password');
  dbms_output.put_line('== .. Email Addr: ^ws_email');

END;
/
PROMPT  =================
PROMPT  ================= CREATING APPLICATIONS 
PROMPT  ================= 
PROMPT
DECLARE 
  l_workspace     varchar2(20) := 'SERT';
  l_workspace_id  number;
  l_app_id_check  number;
BEGIN
  --
  select workspace_id 
    into l_workspace_id 
    from apex_workspaces
   where workspace = l_workspace;
  --
  dbms_output.put_line('== Installing SERT application');
  apex_application_install.set_application_alias('SERT');
  --
  apex_application_install.set_workspace_id( l_workspace_id );
  apex_application_install.generate_offset;
  apex_application_install.generate_application_id;
  --

  exception when no_data_found then 
    dbms_output.put_line('*** ERROR *** SERT workspace does not exist.');
    raise value_error;
END;
/

@@app/f2000.sql

-- Clear installation settings - Prevents collisions 
exec APEX_APPLICATION_INSTALL.CLEAR_ALL;

DECLARE 
  l_workspace     varchar2(20) := 'SERT';
  l_workspace_id  number;
  l_app_id_check  number;
BEGIN
  --
  select workspace_id 
    into l_workspace_id 
    from apex_workspaces
   where workspace = l_workspace;
  --
  dbms_output.put_line('== Installing SERT_ADMIN application');
  apex_application_install.set_application_alias('SERT_ADMIN');
  --
  apex_application_install.set_workspace_id( l_workspace_id );
  apex_application_install.generate_offset;
  apex_application_install.generate_application_id;
  --

  exception when no_data_found then 
    dbms_output.put_line('*** ERROR *** SERT workspace does not exist.');
    raise value_error;
END;
/

@@app/f2001.sql

-- Clear installation settings - Prevents collisions 
exec APEX_APPLICATION_INSTALL.CLEAR_ALL;

PROMPT == .. Applications have been installed 
select WORKSPACE "Workspace"
     , APPLICATION_ID "Application ID"
     , ALIAS "Application Alias"
  from apex_applications
  where ALIAS in ('SERT','SERT_ADMIN');


-- reset the define variable
set define '&'

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
