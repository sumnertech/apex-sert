create or replace view sert_core.eval_results_v
as
with comment_cnt as (select * from comment_cnt_v)
select
   jt.result
  ,listagg(jt.reason, ', ') as reason
  ,er.eval_id
  ,er.eval_result_id
  ,e.rule_set_id
  ,e.workspace_id
  ,er.application_id
  ,er.page_id
  ,er.component_id
  ,er.column_name
  ,er.item_name
  ,er.shared_comp_name
  ,er.current_value
  ,er.valid_values
  ,er.created_by
  ,er.created_on
  ,er.updated_by
  ,er.updated_on
  ,er.rule_id
  ,comment_cnt.cnt as comment_cnt
from
   eval_results er
  ,evals e
  ,comment_cnt
  ,json_table(result, '$' columns
     (
       nested path '$.reasons[*]'
         columns
           (
           reason varchar2(4000) path '$.reason'
           ),
         result varchar2(100) path '$.result'
     )
   ) jt
where
  e.eval_id = er.eval_id
  and er.eval_result_id = comment_cnt.eval_result_id(+)
group by
  jt.result
  ,er.eval_id
  ,er.eval_result_id
  ,e.rule_set_id
  ,e.workspace_id
  ,er.application_id
  ,er.page_id
  ,er.component_id
  ,er.column_name
  ,er.item_name
  ,er.shared_comp_name
  ,er.current_value
  ,er.valid_values
  ,er.created_by
  ,er.created_on
  ,er.updated_by
  ,er.updated_on
  ,er.rule_id
  ,comment_cnt.cnt
/