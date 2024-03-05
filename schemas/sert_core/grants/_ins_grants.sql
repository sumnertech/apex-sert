--    NAME
--      _ins_grants.sql
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
PROMPT = CREATING GRANTS ON SERT_CORE OBJECTS  
PROMPT ==================================================================================
PROMPT 
-- installs grants
@@apex-sert/schemas/sert_core/grants/evals_pub_v.sql
@@apex-sert/schemas/sert_core/grants/rule_sets_pub_v.sql
@@apex-sert/schemas/sert_core/grants/eval_pkg.sql
@@apex-sert/schemas/sert_core/grants/create_job.sql
@@apex-sert/schemas/sert_core/grants/dbms_scheduler.sql
@@apex-sert/schemas/sert_core/grants/eval_results_pub_v.sql
@@apex-sert/schemas/sert_core/grants/rules_pub_v.sql
@@apex-sert/schemas/sert_core/grants/comments_pub_v.sql
@@apex-sert/schemas/sert_core/grants/comments_api.sql
@@apex-sert/schemas/sert_core/grants/exceptions_api.sql
@@apex-sert/schemas/sert_core/grants/exceptions_pub_v.sql
