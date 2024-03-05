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
@@schemas/sert_core/pkg/log_pkg.pks
@@schemas/sert_core/pkg/eval_pkg.pks
@@schemas/sert_core/pkg/rules_pkg.pks
@@schemas/sert_core/pkg/comments_api.pks
@@schemas/sert_core/pkg/exceptions_api.pks


-- install package bodies
@@schemas/sert_core/pkg/log_pkg.pkb
@@schemas/sert_core/pkg/eval_pkg.pkb
@@schemas/sert_core/pkg/rules_pkg.pkb
@@schemas/sert_core/pkg/comments_api.pkb
@@schemas/sert_core/pkg/exceptions_api.pkb
