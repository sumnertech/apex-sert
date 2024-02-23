create or replace view sert_core.evals_pub_v
as
select
   eval_id
  ,workspace_id
  ,workspace
  ,application_id
  ,application_name
  ,last_updated_on
  ,rule_set_id
  ,rule_set_name
  ,rule_set_key
  ,eval_on
  ,eval_on_date
  ,eval_by
  ,summary
  ,job_name
  ,initcap(job_status) as job_status
  ,score
  ,created_by
  ,created_on
  ,updated_by
  ,updated_on
from
  sert_core.evals_v
where
  workspace_id = (select v('WORKSPACE_ID') from dual)
/