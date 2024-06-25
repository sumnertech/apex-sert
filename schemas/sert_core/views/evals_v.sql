create or replace force view sert_core.evals_v
as
select
   e.eval_id
  ,e.workspace_id
  ,a.workspace
  ,w.path_prefix
  ,e.application_id
  ,a.application_name
  ,a.last_updated_on
  ,e.rule_set_id
  ,rs.rule_set_name
  ,rs.rule_set_key
  ,e.eval_on
  ,e.eval_on_date
  ,e.eval_by
  ,e.summary
  ,e.job_name
  ,e.job_status
  ,e.score
  ,e.pending_score
  ,e.approved_score
  ,rs.apex_version
  ,e.created_by
  ,e.created_on
  ,e.updated_by
  ,e.updated_on
from
   evals e
  ,apex_applications a
  ,apex_workspaces w
  ,rule_sets rs
where
  e.application_id = a.application_id
  and e.rule_set_id = rs.rule_set_id
  and a.workspace_id = w.workspace_id(+)
/