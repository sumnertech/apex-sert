create or replace view sert_core.eval_results_v
as
select
   jt.result
  ,listagg(jt.reason, ', ') as reason
  ,er.eval_result_id
  ,er.application_id
  ,er.page_id
  ,er.component_id
  ,er.column_name
  ,er.current_value
  ,er.valid_values
  ,er.created_by
  ,er.created_on
  ,er.updated_by
  ,er.updated_on
  ,er.rule_id
from
   eval_results er
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
group by
  jt.result
  ,er.eval_result_id
  ,er.application_id
  ,er.page_id
  ,er.component_id
  ,er.column_name
  ,er.current_value
  ,er.valid_values
  ,er.created_by
  ,er.created_on
  ,er.updated_by
  ,er.updated_on
  ,er.rule_id
/