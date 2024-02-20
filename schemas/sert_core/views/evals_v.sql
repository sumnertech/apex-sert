create or replace view sert_core.evals_v
as
select
   e.eval_id
  ,e.workspace_id
  ,a.workspace
  ,e.application_id
  ,a.application_name
  ,e.rule_set_id
  ,rs.rule_set_name
  ,rs.rule_set_key
  ,e.eval_on
  ,e.eval_by
  ,e.summary
  ,e.job_name
  ,e.job_status
  ,e.created_by
  ,e.created_on
  ,e.updated_by
  ,e.updated_on
from
   evals e
  ,apex_applications a
  ,rule_sets rs
where
  e.application_id = a.application_id
  and e.rule_set_id = rs.rule_set_id
/