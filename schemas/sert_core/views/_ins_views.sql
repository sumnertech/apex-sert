--    NAME
--      _ins_views.sql
--
--    DESCRIPTION
--      Install views into the SERT_CORE schema
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
PROMPT = CREATING VIEWS IN SERT CORE 
PROMPT ==================================================================================
PROMPT 
-- installs views
@@apex-sert/schemas/sert_core/views/categories_v.sql
@@apex-sert/schemas/sert_core/views/rule_sets_v.sql
@@apex-sert/schemas/sert_core/views/rules_v.sql
@@apex-sert/schemas/sert_core/views/rule_set_rules_v.sql
@@apex-sert/schemas/sert_core/views/rule_criteria_v.sql
@@apex-sert/schemas/sert_core/views/rule_criteria_types_v.sql
@@apex-sert/schemas/sert_core/views/reserved_strings_v.sql
@@apex-sert/schemas/sert_core/views/evals_v.sql
@@apex-sert/schemas/sert_core/views/comments_v.sql
@@apex-sert/schemas/sert_core/views/comment_cnt_v.sql
@@apex-sert/schemas/sert_core/views/rules_relational_to_json_v.sql
@@apex-sert/schemas/sert_core/views/rules_json_to_relational_v.sql
@@apex-sert/schemas/sert_core/views/eval_results_v.sql
@@apex-sert/schemas/sert_core/views/exceptions_v.sql

-- installs pub views
@@apex-sert/schemas/sert_core/views/evals_pub_v.sql
@@apex-sert/schemas/sert_core/views/rule_sets_pub_v.sql
@@apex-sert/schemas/sert_core/views/rules_pub_v.sql
@@apex-sert/schemas/sert_core/views/eval_results_pub_v.sql
@@apex-sert/schemas/sert_core/views/comments_pub_v.sql
@@apex-sert/schemas/sert_core/views/exceptions_pub_v.sql
