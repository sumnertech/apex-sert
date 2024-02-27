create or replace view sert_core.eval_results_pub_v
as
select
   er.eval_result_id
  ,er.eval_id
  ,er.rule_id
  ,er.rule_set_id
  ,r.rule_name
  ,er.workspace_id
  ,er.application_id
  ,er.page_id
  ,case when er.page_id is null then 'Shared Component' else ap.page_name end as page_name
  ,case when er.page_id is not null then er.page_id || ' - ' || ap.page_name else 'Shared Component' end as full_page_name
  ,case when r.impact = 'SC' then shared_comp_type || ' / '|| shared_comp_name else null end 
    || case when er.page_id is not null then er.page_id || ': '  || ap.page_name else null end
    || case when region_name is not null then ' / ' || region_name else null end
    || case when column_name is not null then ' / ' || column_name else null end
    || case when item_name   is not null then ' / ' || item_name   else null end
   as description
  ,er.component_id
  ,apr.region_name
  ,er.column_name
  ,er.shared_comp_name
  ,r.shared_comp_type
  ,er.item_name
  ,r.category_name
  ,r.category_key
  ,er.current_value
  ,er.valid_values
  ,er.result
  ,case when er.result = 'PASS' then 'success' else 'danger' end as result_color
  ,er.reason
  ,case when er.comment_cnt = 0 then null else er.comment_cnt end as comment_cnt
  ,case when er.comment_cnt > 0 then 'fa fa-comments-o' else null end comment_icon
  ,er.created_by
  ,er.created_on
  ,er.updated_by
  ,er.updated_on
  ,risk_name
  ,risk_url
  ,help_url
  ,rule_criteria_type_name
from
   eval_results_v er
  ,rules_pub_v r
  ,apex_application_pages ap
  ,apex_application_page_regions apr
where 1=1
  and workspace_id = (select nv('WORKSPACE_ID') from dual)
  and er.rule_id = r.rule_id
  and nvl(er.page_id, 0) = ap.page_id(+)
  and er.application_id = ap.application_id
  and to_char(er.component_id) = to_char(apr.region_id(+))
/
