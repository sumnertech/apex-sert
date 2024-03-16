alter session set current_schema = sert_core;
set SERVEROUTPUT off;

declare
  p_eval_id_out number;
begin
delete from evals;
for x in (select * from apex_applications where application_id < 120)
loop
eval_pkg.eval
  (
   p_application_id    => x.application_id
--  ,p_page_id           in number   default null
--  ,p_eval_id           in number   default null
  ,p_rule_set_key      => 'INTERNAL'
--  ,p_eval_by           in varchar2 default coalesce(sys_context('APEX$SESSION','APP_USER'),user)
--  ,p_run_in_background in varchar2 default 'Y'
  ,p_eval_id_out       => p_eval_id_out
  );
end loop;
commit;
end;
/

select application_id, job_status, score from evals;
select * from logs where application_id = 100 order by log_id desc
/
select * from apex_applications order by application_id;

with ap as (select * from apex_application_pages where application_id = 2002)
select r.rule_name, er.page_id, ap.page_name, er.component_id, er.column_name, er.result, er.current_value, er.valid_values
 from eval_results_v er, rules_v r, ap where er.rule_id = r.rule_id and er.page_id = ap.page_id(+)  order by  er.page_id, r.rule_name;


delete from evals;
delete from eval_results;
delete from rule_sets;
delete from rules;
commit;

