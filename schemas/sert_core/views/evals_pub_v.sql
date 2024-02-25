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
  ,'Evaluated ' || apex_util.get_since(eval_on) || ' by ' || eval_by
    || case when eval_on_date < last_updated_on then ' / Application updated ' || apex_util.get_since(eval_on_date + (last_updated_on - eval_on_date)) else null end
    as eval_by_long
  ,'r/sert/' || application_id || '/files/static/v16/icons/app-icon-512.png' as app_image
  ,case
    when eval_on_date < last_updated_on then 'Stale'
    else initcap(job_status)
   end as job_status
  ,case
    when eval_on_date < last_updated_on then 'danger'
    when upper(job_status) = 'COMPLETED' then 'success'
    when upper(job_status) = 'FAILED' then 'danger'
    when upper(job_status) = 'RUNNING' then 'warning'
    else null end as job_status_css
  ,nvl(to_char(score),'...') as score
  ,case
    when score < 60 then 'danger'
    when score between 61 and 79 then 'warning'
    when score > 80 then 'success'
    else null
   end as score_css
  ,summary
  ,job_name
  ,created_by
  ,created_on
  ,updated_by
  ,updated_on
from
  sert_core.evals_v
where
  workspace_id = (select nv('WORKSPACE_ID') from dual)
/