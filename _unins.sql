--    NAME
--      _unins.sql
--
--    DESCRIPTION
--
--    NOTES
--      - Requires a user with DBA privileges to be connected. 
--
--    Arguments:
--
--    Example:
--		@_unins.sql
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
PROMPT This will remove the following: 
PROMPT .. The SERT workspace and all applications associated in that workspace. 
PROMPT .. The SERT_CORE database schema
PROMPT .. The SERT_PUB database schema 
PROMPT .. The SERT_REST database schema
PROMPT .. 
PAUSE  .. Press Enter to continue Un-Installation or CTRL-C to EXIT
PROMPT 
PROMPT  =============================================================================
PROMPT  == REMOVE SERT WORKSPACE AND ALL APPLICATIONS 
PROMPT  =============================================================================
PROMPT 
whenever sqlerror continue
--  =================
--  ================= Start The logging 
--  ================= 
column log_name new_val logname NOPRINT
select 'SERT_uninstall_'||to_char(sysdate, 'YYYY-MM-DD_HH24-MI-SS')||'.log' log_name from dual;
-- Spool the log
spool ^logname

begin 
	APEX_INSTANCE_ADMIN.REMOVE_WORKSPACE('SERT','N','N');
end;
/
PROMPT 
PROMPT  =============================================================================
PROMPT  == REMOVE SERT_PUB USER
PROMPT  =============================================================================
PROMPT 
drop user sert_pub cascade
/
PROMPT 
PROMPT  =============================================================================
PROMPT  == REMOVE SERT_REST USER 
PROMPT  =============================================================================
PROMPT 
drop user sert_rest cascade
/
PROMPT 
PROMPT  =============================================================================
PROMPT  == REMOVE SERT_CORE USER
PROMPT  =============================================================================
PROMPT 
drop user sert_core cascade
/
PROMPT  =================================== SERT ==================================
PROMPT
PROMPT  Please check the log file for errors. 
PROMPT  
PROMPT
PROMPT  ============================================================================
PROMPT  ============================= C O M P L E T E ==============================
PROMPT  ============================================================================
spool off