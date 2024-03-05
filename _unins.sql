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
PAUSE   Press Enter to continue Un-Installation or CTRL-C to EXIT
PROMPT .                            
PROMPT . Dropping SERT_PUB user
PROMPT .
drop user sert_pub cascade
/
PROMPT . Dropping SERT_REST user
PROMPT .
drop user sert_rest cascade
/
PROMPT . Dropping SERT_CORE user
PROMPT .
drop user sert_core cascade
/

--exit;
