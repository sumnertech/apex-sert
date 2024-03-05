--    NAME
--      _ins_pkg.sql
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
PROMPT = CREATING PACKAGES IN SERT_CORE
PROMPT ==================================================================================
PROMPT 
-- install package specs
@@apex-sert/schemas/sert_core/pkg/log_pkg.pks
@@apex-sert/schemas/sert_core/pkg/eval_pkg.pks
@@apex-sert/schemas/sert_core/pkg/rules_pkg.pks
@@apex-sert/schemas/sert_core/pkg/comments_api.pks
@@apex-sert/schemas/sert_core/pkg/exceptions_api.pks


-- install package bodies
@@apex-sert/schemas/sert_core/pkg/log_pkg.pkb
@@apex-sert/schemas/sert_core/pkg/eval_pkg.pkb
@@apex-sert/schemas/sert_core/pkg/rules_pkg.pkb
@@apex-sert/schemas/sert_core/pkg/comments_api.pkb
@@apex-sert/schemas/sert_core/pkg/exceptions_api.pkb
