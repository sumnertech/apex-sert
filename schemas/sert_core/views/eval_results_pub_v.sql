create or replace view sert_core.eval_results_pub_v
as
select
   er.eval_result_id
  ,er.eval_id
  ,er.rule_id
  ,r.rule_name
  ,er.workspace_id
  ,er.application_id
  ,er.page_id
  ,case when er.page_id is null then 'Shared Component' else ap.page_name end as page_name
  ,er.component_id
  ,apr.region_name
  ,er.column_name
  ,er.item_name
  ,r.category_name
  ,r.category_key
  ,er.current_value
  ,er.valid_values
  ,er.result
  ,case when er.result = 'PASS' then 'success' else 'danger' end as result_color
  ,er.reason
  ,er.created_by
  ,er.created_on
  ,er.updated_by
  ,er.updated_on
from
   eval_results_v er
  ,rules_pub_v r
  ,apex_application_pages ap
  ,apex_application_page_regions apr
where 1=1
  and er.rule_id = r.rule_id
  and nvl(er.page_id, 0) = ap.page_id(+)
  and er.application_id = ap.application_id
  and to_char(er.component_id) = to_char(apr.region_id(+))
/
