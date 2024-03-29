create or replace view sert_pub.evals_pub_v
as
select
   eval_id
  ,workspace_id
  ,workspace
  ,application_id
  ,application_name
  ,title
  ,last_updated_on
  ,rule_set_id
  ,rule_set_name
  ,rule_set_key
  ,rule_set
  ,eval_on
  ,eval_on_date
  ,eval_by
  ,eval_by_long
  ,app_image
  ,summary
  ,job_name
  ,job_status
  ,job_status_css
  ,score
  ,score_css
  ,exception_cnt
  ,created_by
  ,created_on
  ,updated_by
  ,updated_on
from
  sert_core.evals_pub_v e
/