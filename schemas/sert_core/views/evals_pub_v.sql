create or replace force view sert_core.evals_pub_v
as
with exception_cnt as
(
select
  er.eval_id
 ,sum(cnt) as cnt
from
  exception_cnt_v ec,
  eval_results_v er
where
  er.eval_result_id = ec.eval_result_id(+)
  and er.result = 'PENDING'
group by
  er.eval_id
)
select
   e.eval_id
  ,e.workspace_id
  ,e.workspace
  ,e.application_id
  ,e.application_name
  ,e.application_id || ' : ' || e.application_name as title
  ,e.last_updated_on
  ,e.rule_set_id
  ,e.rule_set_name
  ,e.rule_set_key
  ,'Rule Set: ' || rule_set_name as rule_set
  ,e.eval_on
  ,e.eval_on_date
  ,e.eval_by
  ,'Evaluated ' || apex_util.get_since(eval_on) || ' by ' || eval_by
    || case when eval_on_date < last_updated_on then ' / Application updated ' || apex_util.get_since(eval_on_date + (last_updated_on - eval_on_date)) else null end
    as eval_by_long
  ,'r/wksp_sert/' || application_id || '/files/static/v16/icons/app-icon-512.png' as app_image
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
  ,case when score is null then '...' else score || '%' end as score
  ,case
    when score < 60 then 'danger'
    when score between 61 and 79 then 'warning'
    when score >= 80 then 'success'
    else null
   end as score_css
  ,e.summary
  ,e.job_name
  ,nvl(ec.cnt,0) as exception_cnt
  ,e.created_by
  ,e.created_on
  ,e.updated_by
  ,e.updated_on
from
  sert_core.evals_v e
  ,exception_cnt ec
where 1=1
  and workspace_id = (select nv('G_WORKSPACE_ID') from dual)
  and e.eval_id = ec.eval_id(+)
/