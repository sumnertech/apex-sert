alter session set current_schema = sert_core;
set SERVEROUTPUT off;

begin
delete from evals;
eval_pkg.eval
  (
   p_application_id => 2002
   ,p_debug => true
   ,p_rule_set_key => 'INTERNAL'
--   ,p_rule_set_key => 'REGION_SETTINGS'
  );
  commit;
end;
/

with ap as (select * from apex_application_pages where application_id = 2002)
select r.rule_name, er.page_id, ap.page_name, er.component_id, er.column_name, er.result, er.current_value, er.valid_values
 from eval_results_v er, rules_v r, ap where er.rule_id = r.rule_id and er.page_id = ap.page_id(+)  order by  er.page_id, r.rule_name;



delete from eval_results;
delete from rule_sets;
delete from rules;
commit;
